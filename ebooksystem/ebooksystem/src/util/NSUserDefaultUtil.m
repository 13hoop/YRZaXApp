//
//  NSUserDefaultUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/16.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "NSUserDefaultUtil.h"
#import "Config.h"

@implementation NSUserDefaultUtil


//创建、修改用户当前的学习类型，参数是0,1,2...   key:curStudyType
+ (BOOL)setCurStudyTypeWithType:(NSString *)studyType {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:studyType forKey:@"curStudyType"];
    [userDefault synchronize];
    if ([[userDefault objectForKey:@"curStudyType"] isEqualToString:studyType]) {
        return YES;
    }
    else {
       return NO;
    }
}

//获取用户当前学习类型
+ (NSString *)getCurStudyType {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *curStudyType = [userDefault objectForKey:@"curStudyType"];
    if (curStudyType ==nil || curStudyType.length <= 0) {
        return nil;
    }
    return curStudyType;
}

//存http 请求的相应，为了获取里面的session，里面有session吗？
+ (BOOL)saveHttpResponse:(id)response {
    if (response == nil) {
        return NO;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:response forKey:@"response"];
    [userDefault synchronize];
    return YES;
}

#pragma mark 设置UA
+ (BOOL)setUserAgent {
    NSString *UAString = [Config instance].webConfig.userAgent;
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : UAString, @"User-Agent" : UAString}];
    return YES;
}


@end
