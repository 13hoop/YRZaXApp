//
//  UserConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/28/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserConfig : NSObject

#pragma mark - methods
// singleton
+ (UserConfig *)instance;

// 有关用户充值的提示信息
- (NSString *)tipForUserCharge;

// 用户信息url
- (NSString *)urlForUserInfo;

// 登入url
- (NSString *)urlForLogin;

// 登出url
- (NSString *)urlForLogout;

// 充值url
- (NSString *)urlForCharge;

@end
