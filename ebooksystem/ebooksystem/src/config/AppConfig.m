//
//  AppConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/20/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "AppConfig.h"

@implementation AppConfig

#pragma mark - methods
// singleton
+ (AppConfig *)instance {
    static AppConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

// app version in num
- (NSInteger)appVersionNum {
    return 1; // modify before release
}

@end
