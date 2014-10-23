//
//  ErrorManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/22/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "ErrorManager.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

#import "UncaughtExceptionHandler.h"



@implementation ErrorManager

// custom signal handler
void CustomSignalHandler(int signal) {
    [UncaughtExceptionHandler handleSignal:signal];
}

#pragma mark - singleton
+ (ErrorManager *)instance {
    static ErrorManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[ErrorManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - install uncaught exception handler
+ (BOOL)installUncaughtExceptionHandler {
    signal(SIGABRT, CustomSignalHandler);
    signal(SIGILL, CustomSignalHandler);
    signal(SIGSEGV, CustomSignalHandler);
    signal(SIGFPE, CustomSignalHandler);
    signal(SIGBUS, CustomSignalHandler);
    signal(SIGPIPE, CustomSignalHandler);
    
    return YES;
}

#pragma mark - error report
- (BOOL)sendErrorToServer:(NSString *)error {
    return YES;
}

#pragma mark - crash report
- (BOOL)sendCrashToServer {
//    // 启动后台任务
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // 读crash文件, 回发服务端
//        // [Config instance].errorConfig.crashFilepath
//    });
    
    return YES;
}


@end
