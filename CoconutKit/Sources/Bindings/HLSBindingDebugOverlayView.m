//
//  HLSBindingsDebugOverlayView.m
//  CoconutKit
//
//  Created by Samuel Défago on 02/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingDebugOverlayView.h"

#import "HLSAssert.h"
#import "HLSBindingInformationViewController.h"
#import "UIView+HLSViewBindingFriend.h"
#import "UIView+HLSExtensions.h"

@interface HLSBindingDebugOverlayView ()

@property (nonatomic, weak) UIViewController *debuggedViewController;
@property (nonatomic, strong) UIPopoverController *bindingInformationPopoverController;

@end

@implementation HLSBindingDebugOverlayView

#pragma mark Object creation and destruction

- (id)initWithDebuggedViewController:(UIViewController *)debuggedViewController recursive:(BOOL)recursive
{
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    if (self = [super initWithFrame:applicationFrame]) {
        self.autoresizingMask = HLSViewAutoresizingAll;
        self.alpha = 0.f;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
        self.debuggedViewController = debuggedViewController;
        
        UIGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        [self addGestureRecognizer:gestureRecognizer];
        
        [self refreshDebugInformationForBindingsInView:debuggedViewController.view recursive:recursive];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Debug information display

- (void)show
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController.view addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.f;
    }];
}

- (void)refreshDebugInformationForBindingsInView:(UIView *)view recursive:(BOOL)recursive
{
    if (! recursive && view.nearestViewController != self.debuggedViewController) {
        return;
    }
    
    HLSViewBindingInformation *bindingInformation = view.bindingInformation;
    if (bindingInformation) {
        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = [view convertRect:view.bounds toView:self];
        overlayButton.layer.borderColor = bindingInformation.verified ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
        overlayButton.layer.borderWidth = 2.f;
        overlayButton.userInfo_hls = @{@"bindingInformation" : bindingInformation};
        [overlayButton addTarget:self action:@selector(showInfos:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:overlayButton];
    }
    
    for (UIView *subview in view.subviews) {
        [self refreshDebugInformationForBindingsInView:subview recursive:recursive];
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
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showInfos:(id)sender
{
    NSAssert([sender isKindOfClass:[UIView class]], @"Expect a view");
    UIView *view = sender;
    HLSViewBindingInformation *bindingInformation = view.userInfo_hls[@"bindingInformation"];
    
    HLSBindingInformationViewController *bindingInformationViewController = [[HLSBindingInformationViewController alloc] initWithBindingInformation:bindingInformation];
    self.bindingInformationPopoverController = [[UIPopoverController alloc] initWithContentViewController:bindingInformationViewController];
    [self.bindingInformationPopoverController presentPopoverFromRect:view.frame
                                                              inView:self
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:YES];
}

@end
