//
//  PersionalCenterUrlConfig.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/29.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "PersionalCenterUrlConfig.h"
#import "PathUtil.h"

@implementation PersionalCenterUrlConfig

+ (NSString *)getUrlWithAction:(NSString *)action {
    NSString *bundlePath = [PathUtil getBundlePath];
    //系统详情页
    if ([action isEqualToString:@"system_info"]) {
        NSString *systemInfoUrlStr = [NSString stringWithFormat:@"%@/%@",bundlePath,@"assets/native-html/system_info.html"];
        return systemInfoUrlStr;
    }
    //设置页
    if ([action isEqualToString:@"setting"]) {
        NSString *setPageUrl = [NSString stringWithFormat:@"%@/%@",bundlePath,@"assets/native-html/setting.html"];
        return setPageUrl;
    }
    //充值
    if ([action isEqualToString:@"recharge"]) {
        NSString *rechargeUrlStr = @"http://test.zaxue100.com/index.php?c=salectrl&m=show_recharge_page";
        return rechargeUrlStr;
    }
    //正版验证
    if([action isEqualToString:@"validate"]) {
        NSString *validateUrlStr = @"http://test.zaxue100.com/index.php?c=salectrl&m=show_verify_card_page";
        return validateUrlStr;
    }
    //修改个人信息页
    if([action isEqualToString:@"modify_user_info"]) {
        NSString *modifyUserInfoUrl = @"http://test.zaxue100.com/index.php?c=passportctrl&m=show_userinfo_page&back_to_app=1";
        return modifyUserInfoUrl;
    }
    //用户反馈页面
    if ([action isEqualToString:@"feedback"]) {
        NSString *feedback = @"feedback";
        return feedback;
    }
    
    return nil;
}

@end
