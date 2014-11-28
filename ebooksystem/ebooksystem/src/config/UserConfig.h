//
//  UserConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/28/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserConfig : NSObject

#pragma mark - properties
// 有关用户充值的提示信息
@property (nonatomic, copy, readonly) NSString *tipForUserCharge;

// 用户信息url
@property (nonatomic, copy, readonly) NSString *urlForUserInfo;

// 登入url
@property (nonatomic, copy, readonly) NSString *urlForLogin;

// 登出url
@property (nonatomic, copy, readonly) NSString *urlForLogout;

// 充值url
@property (nonatomic, copy, readonly) NSString *urlForCharge;


#pragma mark - methods
// singleton
+ (UserConfig *)instance;

@end
