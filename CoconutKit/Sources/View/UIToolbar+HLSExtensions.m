//
//  UIToolbar+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UIToolbar+HLSExtensions.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(UIToolbar_HLSExtensions)

@implementation UIToolbar (HLSExtensions)

#pragma mark Accessors and mutators

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    const NSInteger kBackgroundImageViewTag = 28756;         // Very unlikely to be used by another view in the toolbar view hierarchy
    
    UIImageView *backgroundImageView = (UIImageView *)[self viewWithTag:kBackgroundImageViewTag];
    
    // Already added
    if (backgroundImageView) {
        // Changing the existing image
        if (backgroundImage) {
            backgroundImageView.image = backgroundImage;
        }
        // Removing the image
        else {
            [backgroundImageView removeFromSuperview];
        }
    }
    // Adding
    else {
        if (backgroundImage) {
            UIImageView *backgroundImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
            backgroundImageView.image = backgroundImage;
            backgroundImageView.tag = kBackgroundImageViewTag;
            backgroundImageView.contentMode = UIViewContentModeScaleToFill;
            backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            // iOS 5
            if([[[UIDevice currentDevice] systemVersion] intValue] >= 5) {
                [self insertSubview:backgroundImageView atIndex:1];
            }
            else {
                [self insertSubview:backgroundImageView atIndex:0];
            }
        }
    }
}

@end
