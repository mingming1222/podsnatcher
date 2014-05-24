//
//  GGKSameValueSegmentedControl.h
//  example Same-Value Segmented Control
//
//  Created by Geoff Hom on 4/1/14.
//  Copyright (c) 2014 Geoff Hom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGKSameValueSegmentedControl : UISegmentedControl
// Override.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
// Override.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
