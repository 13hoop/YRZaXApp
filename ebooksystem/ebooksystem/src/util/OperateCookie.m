//
//  OperateCookie.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/18.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "OperateCookie.h"

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
    if (dictionary == nil) {
        return NO;
    }
    //sessionID获取有两种方式：（1）请求是从response中获取（2）服务器主动发过来
    NSString *sessionId = [dictionary objectForKey:@"sessionId"];
    //cookie中的key字段是固定的，怎样保存sessionID
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"username" forKey:NSHTTPCookieName];
    [cookieProperties setObject:@"rainbird" forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@"cnrainbird.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"cnrainbird.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    return YES;
}



@end
