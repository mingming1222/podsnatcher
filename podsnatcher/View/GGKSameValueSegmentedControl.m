//
//  GGKSameValueSegmentedControl.m
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKSameValueSegmentedControl.h"

#import "GGKUtilities.h"
#import "UIControl_GGK.h"

@interface GGKSameValueSegmentedControl ()
@end

@implementation GGKSameValueSegmentedControl
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)touchesBegan:(NSSet *)theTouches withEvent:(UIEvent *)theEvent {
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    // If iOS < 7, then selected-segment index is updated here.
    [super touchesBegan:theTouches withEvent:theEvent];
    if ([GGKUtilities iOSisBelow7]) {
        if (self.selectedSegmentIndex == previousSelectedSegmentIndex) {
            [self sendActionsForControlEvents:GGKControlEventValueUnchanged];
        }
    }
}
- (void)touchesEnded:(NSSet *)theTouches withEvent:(UIEvent *)theEvent {
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    // Check whether tap ends in the segmented control. If not, do nothing.
    CGPoint aTouchPoint = [(UITouch *)[theTouches anyObject] locationInView:self];
    // If iOS ≥ 7, then selected-segment index is updated here.
    [super touchesEnded:theTouches withEvent:theEvent];
    if (![GGKUtilities iOSisBelow7] && [self pointInside:aTouchPoint withEvent:theEvent]) {
        if (self.selectedSegmentIndex == previousSelectedSegmentIndex) {
            [self sendActionsForControlEvents:GGKControlEventValueUnchanged];
        }
    }
}
@end
