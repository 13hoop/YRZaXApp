//
//  UserManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UserManager.h"

#import "UserInfo.h"



@implementation UserManager

#pragma mark - singleton
+ (UserManager *)instance {
    static UserManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[UserManager alloc] init];
    });
    
    return sharedInstance;

}

#pragma mark - user related methods
// get cur user
- (UserInfo *)getCurUser {
    // todo: do real work
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.userName = @"user_reg";
    userInfo.password = @"b";
    
    return userInfo;
}

@end
