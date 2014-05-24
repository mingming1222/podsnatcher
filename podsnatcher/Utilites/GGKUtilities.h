//
//  GGKUtilities.h
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GGKUtilities : NSObject
// Return whether device is running iOS less than 7; e.g., 6.1. There were a lot of changes in iOS 7.
+ (BOOL)iOSisBelow7;
@end
