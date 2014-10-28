//
//  UserConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/28/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UserConfig.h"



@implementation UserConfig


#pragma mark - methods
// singleton
+ (UserConfig *)instance {
    static UserConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

// 有关用户充值的提示信息
- (NSString *)tipForUserCharge {
    return @"购买《干货系列》书籍的读者，输入封面验证码可获赠红包余额可用于购买我们即将上线的收费内容";
}

@end
