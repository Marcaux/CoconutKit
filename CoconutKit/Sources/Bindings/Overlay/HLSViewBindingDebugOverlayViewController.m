//
//  HLSViewBindingsDebugOverlayViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingDebugOverlayViewController.h"

#import "HLSLogger.h"
#import "HLSMAKVONotificationCenter.h"
#import "HLSViewBindingInformationViewController.h"
#import "NSBundle+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"
#import "UINavigationController+HLSExtensions.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSExtensions.h"

static UIWindow *s_overlayWindow = nil;
static UIWindow *s_previousKeyWindow = nil;

@interface HLSViewBindingDebugOverlayViewController ()

@property (nonatomic, weak) UIViewController *debuggedViewController;
@property (nonatomic, assign, getter=isRecursive) BOOL recursive;

@property (nonatomic, strong) UIPopoverController *bindingInformationPopoverController;
@property (nonatomic, weak) HLSViewBindingInformationViewController *bindingInformationViewController;

@end

static CGFloat HLSBorderWidthForBindingInformation(HLSViewBindingInformation *bindingInformation);

@implementation HLSViewBindingDebugOverlayViewController

#pragma mark Class methods

+ (void)showForDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive
{
    if (s_overlayWindow) {
        HLSLoggerWarn(@"An overlay is already being displayed");
        return;
    }
    
    s_previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    // Ensure we exit edit mode when displaying the overlay
    [[s_previousKeyWindow firstResponderView] resignFirstResponder];
    
    // Using a second window and setting our overlay as its root view controller ensures that rotation is dealt with correctly
    s_overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    s_overlayWindow.rootViewController = [[HLSViewBindingDebugOverlayViewController alloc] initWithDebuggedViewController:debuggedViewController recursive:recursive];
    [s_overlayWindow makeKeyAndVisible];
}

#pragma mark Class methods

// Recursively collect all scroll views in a given view
+ (NSArray *)scrollViewsInView:(UIView *)view
{
    if ([view isKindOfClass:[UIScrollView class]]) {
        return @[view];
    }
    
    NSMutableArray *scrollViews = [NSMutableArray array];
    for (UIView *subview in view.subviews) {
        [scrollViews addObjectsFromArray:[self scrollViewsInView:subview]];
    }
    return [NSArray arrayWithArray:scrollViews];
}

#pragma mark Object creation and destruction

- (instancetype)initWithDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive
{
    if (self = [super init]) {
        self.debuggedViewController = debuggedViewController;
        self.recursive = recursive;
    }
    return self;
}

#pragma mark View lifecycle

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
    
    UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    [view addGestureRecognizer:gestureRecognizer];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Ensure correct orientation, even if the VC is presented while in landscape orientation
    
    // Since iOS 8: Rotation has completely changed (the view frame only is changed, no rotation transform is applied anymore).
    UIView *previousWindowRootView = s_previousKeyWindow.rootViewController.view;
    if (! [self.view respondsToSelector:@selector(convertRect:toCoordinateSpace:)]) {
        // iOS 7: Apply the same transform as the previous key window
        self.view.transform = previousWindowRootView.transform;
    }
    self.view.frame = [UIScreen mainScreen].bounds;
    
    [self displayDebugInformationForBindingsInView:self.debuggedViewController.view
                            debuggedViewController:self.debuggedViewController
                                         recursive:self.recursive];
    
    __weak __typeof(self) weakSelf = self;
    
    // Follow the motion of underlying views if a scroll view they are in is moved
    NSArray *scrollViews = [HLSViewBindingDebugOverlayViewController scrollViewsInView:previousWindowRootView];
    for (UIScrollView *scrollView in scrollViews) {
        [scrollView addObserver:self keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
            [weakSelf updateButtonFrames];
        }];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateButtonFrames];
}

#pragma mark Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & [self.debuggedViewController supportedInterfaceOrientations];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // Workaround rotation glitches with multiple windows (black screen)
    s_overlayWindow.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // See above
    s_overlayWindow.hidden = NO;
}

#pragma mark Debug information display

- (void)displayDebugInformationForBindingsInView:(UIView *)view
                          debuggedViewController:(UIViewController *)debuggedViewController
                                       recursive:(BOOL)recursive
{
    if (! recursive && view.nearestViewController != debuggedViewController) {
        return;
    }
    
    HLSViewBindingInformation *bindingInformation = view.bindingInformation;
    if (bindingInformation) {
        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = [self overlayViewFrameForView:view];
        
        UIColor *color = nil;
        if (! bindingInformation.verified) {
            color = [UIColor blueColor];
        }
        else {
            color = bindingInformation.error ? [UIColor redColor] : [UIColor greenColor];
        }
        
        // Border with appropriate color and width
        overlayButton.layer.borderColor = color.CGColor;
        overlayButton.layer.borderWidth = HLSBorderWidthForBindingInformation(view.bindingInformation);
        
        // Inner filled for normal fields, with stripes for fields enabled for input
        if ([bindingInformation.view respondsToSelector:@selector(displayedValue)]) {
            overlayButton.backgroundColor = [color colorWithAlphaComponent:0.3f];
        }
        else {
            UIImage *stripesImage = [UIImage coconutKitImageNamed:@"BackgroundStripes.png"];
            UIImage *coloredStripesImage = [[[UIImage imageWithColor:color] imageScaledToSize:stripesImage.size] imageMaskedWithImage:stripesImage];
            overlayButton.backgroundColor = [[UIColor colorWithPatternImage:coloredStripesImage] colorWithAlphaComponent:0.3f];
        }
        
        overlayButton.userInfo_hls = @{ @"bindingInformation" : bindingInformation };
        [overlayButton addTarget:self action:@selector(showInfos:) forControlEvents:UIControlEventTouchUpInside];
        
        // Track frame changes
        __weak UIView *weakView = view;
        __weak __typeof(self) weakSelf = self;
        [view addObserver:self keyPath:@"frame" options:NSKeyValueObservingOptionNew block:^(HLSMAKVONotification *notification) {
            overlayButton.frame = [weakSelf overlayViewFrameForView:weakView];
        }];
        
        [self.view addSubview:overlayButton];
    }
    
    for (UIView *subview in view.subviews) {
        [self displayDebugInformationForBindingsInView:subview debuggedViewController:debuggedViewController recursive:recursive];
    }
}

- (CGRect)overlayViewFrameForView:(UIView *)view
{
    // iOS 8: Since no rotation is applied anymore, we must use another method to convert view frames
    CGRect frame = CGRectZero;
    if ([view respondsToSelector:@selector(convertRect:toCoordinateSpace:)]) {
        frame = [view convertRect:view.bounds toCoordinateSpace:self.view];
    }
    // Pre-iOS 8: The usual conversion gives correct results for views, even in different windows
    else {
        frame = [view convertRect:view.bounds toView:self.view];
    }
    
    // Make the button frame surround the view
    CGFloat borderWidth = HLSBorderWidthForBindingInformation(view.bindingInformation);
    return CGRectMake(CGRectGetMinX(frame) - borderWidth,
                      CGRectGetMinY(frame) - borderWidth,
                      CGRectGetWidth(frame) + 2 * borderWidth,
                      CGRectGetHeight(frame) + 2 * borderWidth);
}

- (void)updateButtonFrames
{
    for (UIButton *overlayButton in self.view.subviews) {
        HLSViewBindingInformation *bindingInformation = [overlayButton.userInfo_hls objectForKey:@"bindingInformation"];
        overlayButton.frame = [self overlayViewFrameForView:bindingInformation.view];
    }
}

#pragma mark UIPopoverControllerDelegate protocol implementation

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.bindingInformationPopoverController = nil;
}

#pragma mark Actions

- (void)close:(id)sender
{
    [s_previousKeyWindow makeKeyAndVisible];
    s_previousKeyWindow = nil;
    
    s_overlayWindow = nil;
}

- (void)showInfos:(id)sender
{
    NSAssert([sender isKindOfClass:[UIButton class]], @"Expect a button");
    UIButton *overlayButton = sender;
    HLSViewBindingInformation *bindingInformation = [overlayButton.userInfo_hls objectForKey:@"bindingInformation"];
    
    HLSViewBindingInformationViewController *bindingInformationViewController = [[HLSViewBindingInformationViewController alloc] initWithBindingInformation:bindingInformation];
    UINavigationController *bindingInformationNavigationController = [[UINavigationController alloc] initWithRootViewController:bindingInformationViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:bindingInformationNavigationController animated:YES completion:nil];
    }
    else {
        
        self.bindingInformationPopoverController = [[UIPopoverController alloc] initWithContentViewController:bindingInformationNavigationController];
        self.bindingInformationPopoverController.delegate = self;
        [self.bindingInformationPopoverController presentPopoverFromRect:overlayButton.frame
                                                                  inView:self.view
                                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                animated:YES];
    }
    
    self.bindingInformationViewController = bindingInformationViewController;
}

@end

#pragma mark Static functions

static CGFloat HLSBorderWidthForBindingInformation(HLSViewBindingInformation *bindingInformation)
{
    return bindingInformation.updatedAutomatically ? 3.f : 1.f;
}
