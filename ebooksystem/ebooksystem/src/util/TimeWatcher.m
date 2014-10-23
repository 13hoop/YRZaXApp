//
//  TimeWatcher.m
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "TimeWatcher.h"

@interface TimeWatcher ()
{
    NSDate *start;
    NSDate *end;
}

@end

@implementation TimeWatcher

- (void)start {
    start = [NSDate date];
}

- (void)stop {
    end = [NSDate date];
}

// 获取耗时字符串
- (NSString *)getIntervalStr {
    double interval = [self getIntervalVal];
    
    long lTime = (long)interval;
    NSInteger iSeconds = lTime % 60;
    NSInteger iMinutes = (lTime / 60) % 60;
    NSInteger iHours = (lTime / 3600);
    NSInteger iDays = lTime/60/60/24;
    NSInteger iMonth = lTime/60/60/24/12;
    NSInteger iYears = lTime/60/60/24/384;
    
    NSString *info = [NSString stringWithFormat:@"%d年%d月%d日%d时%d分%d秒", iYears,iMonth,iDays,iHours,iMinutes,iSeconds];
    return info;
}

// 获取耗时数值, ms
- (double)getIntervalVal {
    double interval = [end timeIntervalSinceReferenceDate] - [start timeIntervalSinceReferenceDate];
    return interval;
}

@end
