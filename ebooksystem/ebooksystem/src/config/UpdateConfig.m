//
//  UpdateConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UpdateConfig.h"

@implementation UpdateConfig


#pragma mark - methods
// singleton
+ (UpdateConfig *)instance {
    static UpdateConfig *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

// 检查更新的url
- (NSString *)urlForCheckUpdate {
    return @"";
}


@end
