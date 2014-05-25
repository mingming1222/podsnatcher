//
//  PlayViewControllerHelper.h
//  podsnatcher
//
//  Created by mingming on 14-5-25.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    int hour;
    int minute;
    int second;
}timePosition;

@interface PlayViewControllerHelper : NSObject

+ (timePosition)getPlayedTime:(double)playedTime;
+ (timePosition)getremainderTimewithDurationTime:(double)durationTime withPlayedTime:(double)playedTime;
@end
