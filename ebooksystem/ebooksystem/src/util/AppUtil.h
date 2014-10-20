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

// 取当前app数字版本号, 配置于AppConfig中
+ (NSInteger)getAppVersionNum;

// 取当前app版本号, 包括app_version.build_version
+ (NSString *)getAppVersionStr;

// 取当前app版本号的app部分
+ (NSString *)getAppVersionPartOfApp;

// 取当前app版本号的build部分
+ (NSString *)getAppVersionPartOfBuild;

@end
