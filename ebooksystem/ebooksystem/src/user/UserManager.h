//
//  UserManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserInfo;



@interface UserManager : NSObject

#pragma mark - singleton
+ (UserManager *)instance;

#pragma mark - user related methods
// get cur user
- (UserInfo *)getCurUser;

@end
