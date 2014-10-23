//
//  TimeWatcher.h
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

// 用来监控代码耗时的工具
@interface TimeWatcher : NSObject

- (void)start;
- (void)stop;
// 获取耗时字符串
- (NSString *)getIntervalStr;
// 获取耗时数值, ms
- (double)getIntervalVal;

@end
