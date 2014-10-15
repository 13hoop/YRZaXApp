//
//  AppUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/14/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "AppUtil.h"

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

// 取当前app版本号
+ (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    CFShow((__bridge CFTypeRef)(infoDictionary));
    
    // app版本
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    return appVersion;
}

// 取当前app版本号
+ (NSString *)getAppBuildVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //    CFShow((__bridge CFTypeRef)(infoDictionary));
    
    // app build版本
    NSString *appBuildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return appBuildVersion;
}

@end
