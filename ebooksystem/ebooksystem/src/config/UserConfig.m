//
//  UserConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/28/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UserConfig.h"



@implementation UserConfig


#pragma mark - properties
// 有关用户充值的提示信息
- (NSString *)tipForUserCharge {
    return @"购买干货系列书籍的读者，输入验证码可获赠红包\n余额可用于购买我们即将上线的收费内容";
}

// 登入url
- (NSString *)urlForLogin {
    return @"http://test.zaxue100.com:8296/index.php?c=passportctrl&m=show_login_page";
}

// 登出url
- (NSString *)urlForLogout {
    return @"http://test.zaxue100.com:8296/index.php?c=passportctrl&m=show_logout_page";
}

// 充值url
- (NSString *)urlForCharge {
    return @"http://test.zaxue100.com:8296/index.php?c=passportctrl&m=show_charge_page";
}

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



@end
