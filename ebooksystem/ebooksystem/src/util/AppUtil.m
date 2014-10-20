//
//  AppUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/14/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "AppUtil.h"

#import "Config.h"



@implementation AppUtil

#pragma mark - method
// 取当前app名称
+ (NSString *)getAppName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    CFShow((__bridge CFTypeRef)(infoDictionary));
    
    // app名称
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    return appName;
}

// 取当前app数字版本号, 配置于AppConfig中
+ (NSInteger)getAppVersionNum {
    return [[Config instance].appConfig appVersionNum];
}

// 取当前app版本号, 包括app_version.build_version
+ (NSString *)getAppVersionStr {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"]];
    return appVersion;
}

// 取当前app版本号的app部分
+ (NSString *)getAppVersionPartOfApp {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
    
    // app版本
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    return appVersion;
}

// 取当前app版本号的build部分
+ (NSString *)getAppVersionPartOfBuild {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    CFShow((__bridge CFTypeRef)(infoDictionary));
    
    // app build版本
    NSString *appBuildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return appBuildVersion;
}

@end
