//
//  LogUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/16/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//
//
//  用法:
//        (1) import "LogUtil.h"
//        (2) LogInfo(formatter, ...);
//
//


#import <Foundation/Foundation.h>

#pragma mark - flags
//#define LOG_TYPE_NSLOG // 使用NSLog
#define LOG_TYPE_DDLOG  // 使用CocoaLumberjack



#pragma mark - log相关宏

#ifdef DEBUGL
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


#ifdef LOG_TYPE_DDLOG

#import "CocoaLumberjack.h"

#define LogError DDLogError
#define LogWarn DDLogWarn
#define LogInfo DDLogInfo
#define LogDebug DDLogDebug
#define LogVerbose DDLogVerbose

#else

#define LogError NSLog
#define LogWarn NSLog
#define LogInfo NSLog
#define LogDebug NSLog
#define LogVerbose NSLog

#endif


//////////////////////////////////CocoaLumberJack Related//////////////////////////////////////////////////////////
////
//// CustomLoggerFormatter
////
@interface CustomLoggerFormatter : NSObject <DDLogFormatter>
{
    int atomicLoggerCount;
    NSDateFormatter *threadUnsafeDateFormatter;
}
@end


@interface LogUtil : NSObject

// 配置log.
// 用法: 在AppDelegate.m中的application:didFinishLaunchingWithOptions:中调用一次即可.
+ (BOOL)init;

// 用法: 在AppDelegate.m中, 只调一次
+ (BOOL)uninit;

// 获取log文件所在路径
+ (NSString *)getLogFilePath;

@end
