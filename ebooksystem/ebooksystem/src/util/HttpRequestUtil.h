//
//  HttpRequestUtil.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/10.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"


@interface HttpRequestUtil : NSObject

#pragma mark -- get/post 请求，供页面调用的方法

//在调用时需要开异步线程来执行
//get请求
+ (void)httpGetWithUrl:(NSString *)url andHeader:(NSDictionary *)headerDic  andResponseCallBack:(WVJBResponseCallback)responseCallBack;

//post请求
+ (void)httpPostWithUrl:(NSString *)url andHeader:(NSDictionary *)headerDic andBody:(NSDictionary *)bodyDic andResponseCallBack:(WVJBResponseCallback)responseCallBack;


@end
