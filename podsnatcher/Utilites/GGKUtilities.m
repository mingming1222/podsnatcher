//
//  GGKUtilities.m
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import "GGKUtilities.h"

@implementation GGKUtilities
+ (BOOL)iOSisBelow7 {
    // From Apple iOS 7 UI Transition Guide: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/SupportingEarlieriOS.html
    return floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
}
@end
