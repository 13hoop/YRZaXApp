//
//  WebUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebUtil : NSObject

#pragma mark - methods

// 检查网络请求中的User-Agent字段
+ (BOOL)checkUserAgent;

/**
 * quest
 *
 * url:请求地址
 * verb:请求方式
 * parameters:请求参数
 */
+ (NSString *)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withHeader:(NSDictionary *)headers andData:(NSDictionary *)data;

@end
