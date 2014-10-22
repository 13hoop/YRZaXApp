//
//  ErrorManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/22/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "ErrorManager.h"

@implementation ErrorManager


#pragma mark - singleton
+ (ErrorManager *)instance {
    static ErrorManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[ErrorManager alloc] init];
    });
    
    return sharedInstance;
    
}

#pragma mark - error report
- (BOOL)sendErrorToServer:(NSString *)error {
    return YES;
}

#pragma mark - crash report
- (BOOL)sendCrashToServer {
    return YES;
}


@end
