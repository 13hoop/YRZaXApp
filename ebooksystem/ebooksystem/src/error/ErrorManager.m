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

#import "Config.h"
#import "UserManager.h"

#import "WebUtil.h"
#import "DeviceUtil.h"
#import "AppUtil.h"
#import "LogUtil.h"
#import "PathUtil.h"


@interface ErrorManager ()

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;

@end

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

- (BOOL)sendCrashToServer {
    // 启动后台任务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 读crash文件, 回发服务端
        // [Config instance].errorConfig.crashFilepath
        UserInfo *curUserInfo = [[UserManager instance] getCurUser];
        
        // Url
        NSString *url = [Config instance].errorConfig.errorUrlByPost;
        
        // headers
        NSString *userAgent = [Config instance].webConfig.userAgent;
        
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
        [headers setValue:userAgent forKey:@"user_agent"];
        
        // body params
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        [data setValue:userAgent forKey:@"user_agent"];
        [data setValue:@"0" forKey:@"encrypt_method"]; // 不加密
        [data setValue:@"0" forKey:@"encrypt_key_type"];
        [data setValue:@"1" forKey:@"app_platform"]; // ios
        {
            NSString *appVersion = [NSString stringWithFormat:@"%ld", (long)[AppUtil getAppVersionNum]];
            [data setValue:appVersion forKey:@"app_version"]; // app version
        }
        [data setValue:(curUserInfo ? curUserInfo.username : @"") forKey:@"user_name"];
        
        // device id
        {
            NSString *deviceId = [DeviceUtil getVendorId];
            [data setValue:deviceId forKey:@"device_id"];
        }
        
        // param data
        {
//            [self showAlertWithTitle:@"ErrorManager" andMessage:@"准备读文件"];
            NSError *error = nil;
            NSString *errorLog = [NSString stringWithContentsOfFile:[Config instance].errorConfig.crashFilepath encoding:NSUTF8StringEncoding error:&error];
            if (errorLog == nil || errorLog.length <= 0) {
//                [self showAlertWithTitle:@"ErrorManager" andMessage:[NSString stringWithFormat:@"读文件失败, error: %@", error]];
                return;
            }
            
            NSString *errorData = [NSString stringWithFormat:@"[%@]", errorLog];
            [data setValue:errorData forKey:@"data"];
            
//            [self showAlertWithTitle:@"ErrorManager" andMessage:[NSString stringWithFormat:@"读文件成功, data: %@", data]];
            
            LogInfo(@"[ErrorManager-sendCrashToServer] will send error data: %@", data);
        }
        
        // 发送web请求, 获取响应
        NSString *serverResponseStr = [WebUtil sendRequestTo:[NSURL URLWithString:url] usingVerb:@"POST" withHeader:headers andData:data];
        
        LogInfo(@"[ErrorManager-sendCrashToServer] sent error finished");
//        [self showAlertWithTitle:@"ErrorManager" andMessage:[NSString stringWithFormat:@"发送成功, response: %@", serverResponseStr]];
        
        [PathUtil deletePath:[Config instance].errorConfig.crashFilepath];
        
        return;
    });
    
    return YES;
}


@end
