//
//  AppUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/14/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject

#pragma mark - method
// 取app名称
+ (NSString *)getAppName;

// 取当前app版本号
+ (NSString *)getAppVersion;

// 取当前app版本号
+ (NSString *)getAppBuildVersion;

@end
