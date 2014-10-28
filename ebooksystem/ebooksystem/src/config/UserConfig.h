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

@end
