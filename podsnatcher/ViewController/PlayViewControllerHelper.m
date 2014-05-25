//
//  PlayViewControllerHelper.m
//  podsnatcher
//
//  Created by mingming on 14-5-25.
//  Copyright (c) 2014年 mingming. All rights reserved.
//

#import "PlayViewControllerHelper.h"

@implementation PlayViewControllerHelper

+ (timePosition)getPlayedTime:(double)playedTime
{
    NSInteger alreadyHour = (playedTime/3600);
    NSInteger alreadyMinute = (playedTime-alreadyHour*3600)/60;
    NSInteger alreadySecond = (playedTime-alreadyHour*3600-alreadyMinute*60);

    timePosition time;
    time.hour = alreadyHour;
    time.minute = alreadyMinute;
    time.second = alreadySecond;
    
    return time;
}

+ (timePosition)getremainderTimewithDurationTime:(double)durationTime withPlayedTime:(double)playedTime
{
    
    int remainderTime = durationTime - playedTime;
    int remainderHour = (remainderTime/3600);
    int remainderMinute = (remainderTime-remainderHour*3600)/60;
    int remainderSecond = (remainderTime-remainderHour*3600-remainderMinute*60);
    
    timePosition time;
    time.hour = remainderHour;
    time.minute = remainderMinute;
    time.second = remainderSecond;
    
    return time;
}
@end
