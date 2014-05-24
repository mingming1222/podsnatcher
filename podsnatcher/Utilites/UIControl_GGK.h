//
//  UIControl_GGK.h
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

// Custom UIControlEvent. If additional events needed, read this: http://stackoverflow.com/questions/865776/understanding-objective-c-enum-declaration.
enum {
    GGKControlEventValueUnchanged = 1 << 24
};

@interface UIControl ()
@end
