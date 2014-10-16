//
//  LogUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/16/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "LogUtil.h"

#import <libkern/OSAtomic.h>



@implementation CustomLoggerFormatter

- (NSString *)stringFromDate:(NSDate *)date
{
    NSString *dateFormatString = @"yyyy-MM-dd HH:mm:ss:SSS";
    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCount);
    
    if (loggerCount <= 1)
    {
        // Single-threaded mode.
        
        if (threadUnsafeDateFormatter == nil)
        {
            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
            [threadUnsafeDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [threadUnsafeDateFormatter setDateFormat:dateFormatString];
        }
        
        return [threadUnsafeDateFormatter stringFromDate:date];
    }
    else
    {
        // Multi-threaded mode.
        // NSDateFormatter is NOT thread-safe.
        
        NSString *key = @"MyCustomFormatter_NSDateFormatter";
        
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
        
        if (dateFormatter == nil)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [dateFormatter setDateFormat:dateFormatString];
            
            [threadDictionary setObject:dateFormatter forKey:key];
        }
        
        return [dateFormatter stringFromDate:date];
    }
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR : logLevel = @"ERROR"; break;
        case LOG_FLAG_WARN  : logLevel = @"WARN"; break;
        case LOG_FLAG_INFO  : logLevel = @"INFO"; break;
        case LOG_FLAG_DEBUG : logLevel = @"DEBUG"; break;
        default             : logLevel = @"VERBOSE"; break;
    }
    
    NSString *dateAndTime = [self stringFromDate:(logMessage->timestamp)];
    NSString *logMsg = logMessage->logMsg;
    
    return [NSString stringWithFormat:@"[%@] | %@ | %@\n", dateAndTime, logLevel, logMsg];
}

- (void)didAddToLogger:(id <DDLogger>)logger
{
    OSAtomicIncrement32(&atomicLoggerCount);
}
- (void)willRemoveFromLogger:(id <DDLogger>)logger
{
    OSAtomicDecrement32(&atomicLoggerCount);
}


@end




@implementation LogUtil

// 配置log.
// 用法: 在AppDelegate.m中的application:didFinishLaunchingWithOptions:中调用一次即可.
+ (BOOL)init {
#ifdef LOG_TYPE_DDLOG
    [DDLog removeAllLoggers];
    
    
    CustomLoggerFormatter *customLoggerFormatter = [[CustomLoggerFormatter alloc] init];
    
    // DDASLLogger
    {
        DDASLLogger* asLogger = [DDASLLogger sharedInstance];
        [asLogger setLogFormatter: customLoggerFormatter];
        [DDLog addLogger: asLogger];
    }
    
    // DDTTYLogger
    {
        DDTTYLogger* ttyLogger = [DDTTYLogger sharedInstance];
        [ttyLogger setLogFormatter: customLoggerFormatter];
        [DDLog addLogger: ttyLogger];
    }
    
    // DDFileLogger
    {
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        fileLogger.maximumFileSize = (1024 * 1024 * 2); // 10 MB
        fileLogger.rollingFrequency = (60 * 60 * 24);   // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // 7 days
        
        [fileLogger setLogFormatter: customLoggerFormatter];
        [DDLog addLogger:fileLogger];
    }
#endif

    return YES;
}

// 用法: 在AppDelegate.m中, 只调一次
+ (BOOL)uninit {
#ifdef LOG_TYPE_DDLOG
    [DDLog removeAllLoggers];
#endif
    
    return YES;
}

// 获取log文件所在路径
+ (NSString *)getLogFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [paths objectAtIndex:0];

    return [NSString stringWithFormat:@"%@/Logs", cachesPath];
}

@end
