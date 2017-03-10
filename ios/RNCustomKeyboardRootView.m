//
//  RNCustomKeyboardRootView.m
//  RNCustomKeyboard
//
//  Created by Simon Mitchell on 10/03/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNCustomKeyboardRootView.h"
#import <React/RCTView.h>
#import <React/RCTScrollView.h>

@interface RNCustomKeyboardRootView ()

@property (nonatomic, assign) BOOL removedYellowBox;

@end

@implementation RNCustomKeyboardRootView

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.removedYellowBox) {
        self.removedYellowBox = [self removeYellowBox];
    }
}

- (NSArray*)getAllSubviewsForView:(UIView*)view
{
    NSMutableArray *allSubviews = [NSMutableArray new];
    for (UIView *subview in view.subviews)
    {
        [allSubviews addObject:subview];
        [allSubviews addObjectsFromArray:[self getAllSubviewsForView:subview]];
    }
    return allSubviews;
}

/*
 The YellowBox is added to each RCTRootView. Regardless if there are warnings or not, if there's a warning anywhere in the app - it is added
 Since it is always appears on the top, it blocks interactions with other components.
 It is most noticeable in RCCLightBox and RCCNotification where button (for example) are not clickable if placed at the bottom part of the view
 */

- (BOOL)removeYellowBox
{
#ifndef DEBUG
    return YES;
#endif
    
    BOOL removed = NO;
    
    NSArray* subviews = [self getAllSubviewsForView:self];
    for (UIView *view in subviews)
    {
        if ([view isKindOfClass:[RCTView class]])
        {
            CGFloat r, g, b, a;
            [view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
            
            //identify the yellow view by its hard-coded color and height
            if((lrint(r * 255) == 250) && (lrint(g * 255) == 186) && (lrint(b * 255) == 48) && (lrint(a * 100) == 95) && (view.frame.size.height == 46))
            {
                UIView *yelloboxParentView = view;
                while (view.superview != nil)
                {
                    yelloboxParentView = yelloboxParentView.superview;
                    if ([yelloboxParentView isKindOfClass:[RCTScrollView class]])
                    {
                        yelloboxParentView = yelloboxParentView.superview;
                        break;
                    }
                }
                
                [yelloboxParentView removeFromSuperview];
                removed = YES;
                break;
            }
        }
        
        if (removed)
        {
            break;
        }
    }
    
    return removed;
}


@end
