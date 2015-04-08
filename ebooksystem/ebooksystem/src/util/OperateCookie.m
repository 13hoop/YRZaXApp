//
//  OperateCookie.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/18.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "OperateCookie.h"
#import "DeviceUtil.h"
#import "AppUtil.h"
#import "NSUserDefaultUtil.h"


@implementation OperateCookie
//1 查看当前的cookie
+ (BOOL)checkCookie {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"current cookie ==== %@", cookie);
    }
    return YES;
}

//设置cookie中的值
+ (BOOL)setCookieWithCustomKeyAndValue:(NSDictionary *)dictionary {
//    if (dictionary == nil) {
//        return NO;
//    }
    //sessionID获取有两种方式：（1）请求是从response中获取（2）服务器主动发过来
    NSString *sessionId = [dictionary objectForKey:@"sessionId"];
    //cookie中的key字段是固定的，怎样保存sessionID
    
    
    
    
    NSString *device_id=[DeviceUtil getVendorId];
    NSString *currentVersion = [AppUtil getAppVersionStr];
    NSString *appVersionString = [NSString stringWithFormat:@"%@-",currentVersion];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"zaxue_did" forKey:NSHTTPCookieName];
    [cookieProperties setObject:device_id forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    
    
    
    NSMutableDictionary *secondCookieProperties = [NSMutableDictionary dictionary];
    [secondCookieProperties setObject:@"zaxue_app_channel" forKey:NSHTTPCookieName];
    [secondCookieProperties setObject:@"AppStore" forKey:NSHTTPCookieValue];
    [secondCookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieDomain];
    [secondCookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieOriginURL];
    [secondCookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [secondCookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie2 = [[NSHTTPCookie alloc] initWithProperties:secondCookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie2];

    
    
    
    NSMutableDictionary *thirdCookieProperties = [NSMutableDictionary dictionary];
    
    [thirdCookieProperties setObject:@"zaxue_app_version" forKey:NSHTTPCookieName];
    [thirdCookieProperties setObject:appVersionString forKey:NSHTTPCookieValue];
    [thirdCookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieDomain];
    [thirdCookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieOriginURL];
    [thirdCookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [thirdCookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie3 = [[NSHTTPCookie alloc] initWithProperties:thirdCookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie3];
    
    
    NSMutableDictionary *FourthCookieProperties = [NSMutableDictionary dictionary];
    NSString *zaxueUserIdString = [NSUserDefaultUtil getUserId];
    if (zaxueUserIdString == nil || zaxueUserIdString.length <= 0) {
        zaxueUserIdString = @"";
    }
    
    [FourthCookieProperties setObject:@"zaxue_uid" forKey:NSHTTPCookieName];
    [FourthCookieProperties setObject:zaxueUserIdString forKey:NSHTTPCookieValue];
    [FourthCookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieDomain];
    [FourthCookieProperties setObject:@".zaxue100.com" forKey:NSHTTPCookieOriginURL];
    [FourthCookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [FourthCookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    NSHTTPCookie *cookie4 = [[NSHTTPCookie alloc] initWithProperties:FourthCookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie4];
    
    
    
    
    
    
    NSLog(@"修改成功了木有========%@",[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    return YES;
}

//


@end
