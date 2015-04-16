//
//  OperateCookie.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/18.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperateCookie : NSObject

//1 查看当前的cookie
+ (BOOL)checkCookie;
//2 设置cookie
+ (BOOL)setCookieWithCustomKeyAndValue:(NSDictionary *)dictionary;
//3

@end
