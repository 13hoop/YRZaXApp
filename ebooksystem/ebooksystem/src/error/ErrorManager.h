//
//  ErrorManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/22/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorManager : NSObject


#pragma mark - singleton
+ (ErrorManager *)instance;

#pragma mark - install uncaught exception handler
+ (BOOL)installUncaughtExceptionHandler;
//void InstallUncaughtExceptionHandler();

#pragma mark - error report
- (BOOL)sendErrorToServer:(NSString *)error;

#pragma mark - crash report
- (BOOL)sendCrashToServer;


@end
