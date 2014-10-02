//
//  LabelBindingsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 29.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "LabelBindingsDemoViewController.h"

@interface LabelBindingsDemoViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation LabelBindingsDemoViewController {
@private
    NSUInteger _currentPageIndex;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *debugOverlayBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Debug", nil)
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(showBindingDebugOverlay:)];
    self.navigationItem.rightBarButtonItems = [@[debugOverlayBarButtonItem] arrayByAddingObjectsFromArray:self.navigationItem.rightBarButtonItems];
    
    [self displayPageAtIndex:_currentPageIndex animated:NO];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"Keypaths & formatters", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"View hierarchies", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTitle:NSLocalizedString(@"VC hierarchies", nil) forSegmentAtIndex:2];
    [self.segmentedControl setTitle:NSLocalizedString(@"Lookup failures", nil) forSegmentAtIndex:3];
    [self.segmentedControl setTitle:NSLocalizedString(@"Dangling views", nil) forSegmentAtIndex:4];
    
    self.title = NSLocalizedString(@"Labels", nil);
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Pages

- (void)displayPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSString *viewControllerClassName = [NSString stringWithFormat:@"LabelBindingsDemo%dViewController", index + 1];
    Class viewControllerClass = NSClassFromString(viewControllerClassName);
    if (! viewControllerClass) {
        HLSLoggerError(@"Unknown class %@", viewControllerClassName);
        return;
    }
    
    _currentPageIndex = index;
    
    self.segmentedControl.selectedSegmentIndex = index;
    
    UIViewController *viewController = [[viewControllerClass alloc] init];
    
    Class transitionClass = animated ? [HLSTransitionCrossDissolve class] : [HLSTransitionNone class];
    [self setInsetViewController:viewController atIndex:0 withTransitionClass:transitionClass];
}

#pragma mark Action callbacks

- (IBAction)changePage:(id)sender
{
    [self displayPageAtIndex:self.segmentedControl.selectedSegmentIndex animated:YES];
}

- (IBAction)showBindingDebugOverlay:(id)sender
{
    [self showBindingDebugOverlayViewRecursive:YES];
}

@end
