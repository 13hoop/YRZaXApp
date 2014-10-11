//
//  DateUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/11/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

// 当前时间
+ (NSDate *)date {
    return [NSDate date];
}

// 当前时间戳
+ (NSString *)timestamp {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    return [formatter stringFromDate:[NSDate date]];
}


@end
