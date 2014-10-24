//
//  UncaughtExceptionHandler.m
//  ebooksystem
//
//  Created by zhenghao on 10/22/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UncaughtExceptionHandler.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

#import "Config.h"

#import "ErrorInfo.h"

#import "LogUtil.h"





NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";

NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;

const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;

const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;


@interface UncaughtExceptionHandler ()
{
    BOOL dismissed;
}


+ (NSString *)getAppInfo;
+ (ErrorInfo *)getErrorInfo:(NSInteger)signal;
+ (NSArray *)backtrace;

- (void)handleError:(ErrorInfo *)errorInfo;
//- (void)handleException:(NSException *)exception;

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex;

@end



@implementation UncaughtExceptionHandler

+ (NSString *)getAppInfo {
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\nUDID : %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion,
                         [UIDevice currentDevice].identifierForVendor];
    
    return appInfo;
}

+ (NSArray *)backtrace {
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (
         int i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount;
         ++i) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return backtrace;
}

+ (ErrorInfo *)getErrorInfo:(NSInteger)signal {
    ErrorInfo *errorInfo = [[ErrorInfo alloc] init];
    
    errorInfo.errorName = UncaughtExceptionHandlerSignalExceptionName;
    errorInfo.errorName = @"UncaughtExceptionHandlerSignalException";
    errorInfo.errorDesc = [NSString stringWithFormat:@"time: %@", [NSDate date]];
    
    errorInfo.model = [UIDevice currentDevice].model;
    errorInfo.systemName = [UIDevice currentDevice].systemName;
    errorInfo.systemVersion = [UIDevice currentDevice].systemVersion;
    errorInfo.identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    
    errorInfo.bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    errorInfo.bundleShortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    errorInfo.bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    errorInfo.stack = [UncaughtExceptionHandler backtrace];
    
    // exception
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
        NSArray *callStack = [UncaughtExceptionHandler backtrace];
        [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
        
        errorInfo.exception =
            [NSException
             exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
             reason:[NSString stringWithFormat:
                            NSLocalizedString(@"Signal %d was raised.\n%@", nil),
                            signal, [UncaughtExceptionHandler getAppInfo]]
             userInfo:
                [NSDictionary
                 dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]];
    }
    
    return errorInfo;
}

+ (void)handleSignal:(NSInteger)signal {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    ErrorInfo *errorInfo = [UncaughtExceptionHandler getErrorInfo:signal];
    if (errorInfo == nil) {
        return;
    }
    
    [[[UncaughtExceptionHandler alloc] init]
        performSelectorOnMainThread:@selector(handleError:)
        withObject:errorInfo
        waitUntilDone:YES];
}

- (void)handleError:(ErrorInfo *)errorInfo {
    // 1. 将错误日志保存到文件
    NSString *messageForAnalysis = [errorInfo toJSONString];
    // test
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"程序异常提示", nil)
//                                                            message:(messageForAnalysis == nil ? @"nil" : messageForAnalysis)
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"退出", nil)
//                                              otherButtonTitles:nil];
//        [alertView show];
//    }
    
    if (messageForAnalysis != nil) {
        NSError *error = nil;
        [messageForAnalysis writeToFile:[Config instance].errorConfig.crashFilepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error != nil) {
            LogError(@"[UncaughtExceptionHandler-handleException:] failed to save crash report to file: %@, error: %@", [Config instance].errorConfig.crashFilepath, error.localizedDescription);
            
            NSString *info = [NSString stringWithFormat:@"[UncaughtExceptionHandler-handleException:] failed to save crash report to file: %@, error: %@", [Config instance].errorConfig.crashFilepath, error.localizedDescription];
            
//            [self showAlertWithTitle:@"UncaughtExceptionHandler" andMessage:info];
        }
        else {
            LogError(@"[UncaughtExceptionHandler-handleException:] successfully to save crash report to file: %@", [Config instance].errorConfig.crashFilepath);
            
            NSString *info = [NSString stringWithFormat:@"[UncaughtExceptionHandler-handleException:] successfully to save crash report to file: %@, error: %@", [Config instance].errorConfig.crashFilepath, error.localizedDescription];
            
//            [self showAlertWithTitle:@"UncaughtExceptionHandler" andMessage:info];
        }
    }
    
    // 2. 弹出窗口, 提示用户
    NSString *messageForUser = @"\n程序遇到未知错误, 需要退出.\n对于给您带来的不便, 在此深表歉意.\n";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"程序异常提示", nil)
                                                    message:messageForUser
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"退出", nil)
                                          otherButtonTitles:nil];
    
    [alert show];
    
    // 3. 退出app
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    
    NSSetUncaughtExceptionHandler(NULL);
    
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([errorInfo.errorName isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[errorInfo.exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else {
        [errorInfo.exception raise];
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"退出", nil)
                                              otherButtonTitles:nil];
        
        [alert show];
    });
}


//+ (void)handleSignal:(NSInteger)signal {
//    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
//    
//    if (exceptionCount > UncaughtExceptionMaximum) {
//        return;
//    }
//    
//    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
//    
//    NSArray *callStack = [UncaughtExceptionHandler backtrace];
//    
//    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
//    
//    [[[UncaughtExceptionHandler alloc] init]
//        performSelectorOnMainThread:@selector(handleException:)
//        withObject:[NSException
//                 exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
//                 reason:[NSString stringWithFormat:
//                                    NSLocalizedString(@"Signal %d was raised.\n%@", nil),
//                                    signal, [UncaughtExceptionHandler getAppInfo]]
//                 userInfo:
//                    [NSDictionary
//                        dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]]
//        waitUntilDone:YES];
//}


- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    if (anIndex == 0) {
        dismissed = YES;
    }
}

//- (void)handleException:(NSException *)exception {
//    // 将错误日志保存到文件
//    NSString *message = [NSString stringWithFormat:NSLocalizedString(
//                                                                     @"You can try to continue but the application may be unstable.\n"
//                                                                     @"%@\n%@", nil),
//                         [exception reason],
//                         [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
//    
//    NSError *error = nil;
//    [message writeToFile:[Config instance].errorConfig.crashFilepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    if (error != nil) {
//        LogError(@"[UncaughtExceptionHandler-handleException:] failed to save crash report to file: %@, error: %@", [Config instance].errorConfig.crashFilepath, error.localizedDescription);
//    }
//    else {
//        LogError(@"[UncaughtExceptionHandler-handleException:] successfully to save crash report to file: %@", [Config instance].errorConfig.crashFilepath);
//    }
//    
////    return;
//    
//    
//    NSString *messageForUser = @"\n程序遇到未知错误, 需要退出.\n\n对于给您带来的不便, 在此深表歉意.\n";
//    
//    
//    // 弹出窗口, 提示用户
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"程序异常提示", nil)
//                                              message:messageForUser
//                                              delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"Quit", nil)
//                                              otherButtonTitles:nil];
////                                           otherButtonTitles:NSLocalizedString(@"Continue", nil), nil];
//    
//    [alert show];
//    
//    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
//    
//    while (!dismissed) {
//        for (NSString *mode in (__bridge NSArray *)allModes) {
//            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
//        }
//    }	
//    
//    CFRelease(allModes);
//    
//    
//    NSSetUncaughtExceptionHandler(NULL);
//    
//    signal(SIGABRT, SIG_DFL);
//    signal(SIGILL, SIG_DFL);
//    signal(SIGSEGV, SIG_DFL);
//    signal(SIGFPE, SIG_DFL);
//    signal(SIGBUS, SIG_DFL);
//    signal(SIGPIPE, SIG_DFL);
//    
//    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
//        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
//    }
//    else {
//        [exception raise];
//    }
//}

@end
