//
//  HttpRequestUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/10.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "HttpRequestUtil.h"
#import "Config.h"
#import "SBJson.h"

@implementation HttpRequestUtil
//get请求
+ (void)httpGetWithUrl:(NSString *)url andHeader:(NSDictionary *)headerDic  andResponseCallBack:(WVJBResponseCallback)responseCallBack {
    
    
    NSString *contentType = @"text/html; charset=utf-8";
    NSString *userAgent = [Config instance].webConfig.userAgent;//取得UA
    NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] init];
    [requestHeaders setValue:contentType forKey:@"Content-Type"];
    [requestHeaders setValue:@"text/html" forKey:@"Accept"];
    [requestHeaders setValue:@"no-cache" forKey:@"Cache-Control"];
    [requestHeaders setValue:@"no-cache" forKey:@"Pragma"];
    [requestHeaders setValue:@"close" forKey:@"Connection"];
    if (userAgent != nil && userAgent.length > 0 ) {
        [requestHeaders setValue:userAgent forKey:@"User-Agent"];
    }
    
    //1 判断header中是否有键值对，若是有则存储，否则不存储
    if (headerDic != nil && [headerDic allKeys].count > 0) {
        NSArray *keyArray = [headerDic allKeys];
        for (NSString *tempKey in keyArray) {
            NSString *tempValue = [headerDic objectForKey:tempKey];
            [requestHeaders setValue:tempValue forKey:tempKey];
        }
    }
    
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [mutableRequest setAllHTTPHeaderFields:requestHeaders];
    [mutableRequest setHTTPMethod:@"GET"];
      //status : '', msg : '', http_code : 'http状态码', response : '服务器返回的内容'
    // 2 处理请求得到的结果
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    NSString *responseString =  nil;
    NSString *statusString = nil;
    NSString *httpCodeString;
    NSString *msgString = nil;
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
    if (error) {//get 请求失败
        statusString = @"-1";
        httpCodeString = [NSString stringWithFormat:@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]];
        msgString = error.localizedDescription;
        if (data == nil) {
            responseString = @"";
        }
        else {// 请求成功
            responseString = (NSString *)data;
        }
        
    }
    else {
        statusString = @"0";
        httpCodeString = [NSString stringWithFormat:@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]];
        msgString = @"";
        responseString = (NSString *)data;
    }
    [resultDic setValue:statusString forKey:@"status"];
    [resultDic setValue:msgString forKey:@"msg"];
    [resultDic setValue:httpCodeString forKey:@"http_code"];
    [resultDic setValue:responseString forKey:@"response"];
    // 3 将resultDic转成JSON字符串
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *resultString = [writer stringWithObject:resultDic];
    // 4 回调给JS
    if (responseCallBack != nil) {
        responseCallBack (resultString);
    }
    
    
}

//post请求
+ (void)httpPostWithUrl:(NSString *)url andHeader:(NSDictionary *)headerDic andBody:(NSDictionary *)bodyDic andResponseCallBack:(WVJBResponseCallback)responseCallBack {
    
    //1 设置请求头
    NSString *contentType = @"text/html; charset=utf-8";
    NSString *userAgent = [Config instance].webConfig.userAgent;//取得UA
    NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] init];
    [requestHeaders setValue:contentType forKey:@"Content-Type"];
    [requestHeaders setValue:@"text/html" forKey:@"Accept"];
    [requestHeaders setValue:@"no-cache" forKey:@"Cache-Control"];
    [requestHeaders setValue:@"no-cache" forKey:@"Pragma"];
    [requestHeaders setValue:@"close" forKey:@"Connection"];
    if (userAgent != nil && userAgent.length > 0 ) {
        [requestHeaders setValue:userAgent forKey:@"User-Agent"];
    }
    
    //
    if (headerDic != nil && [headerDic allKeys].count > 0) {
        NSArray *keyArray = [headerDic allKeys];
        for (NSString *tempKey in keyArray) {
            NSString *tempValue = [headerDic objectForKey:tempKey];
            [requestHeaders setValue:tempValue forKey:tempKey];
        }
    }
    
    //2 设置请求体
    //post还得单独拼一个参数的字符串
    NSMutableString *bodyStr = [NSMutableString stringWithCapacity:0];
    if (bodyDic != nil && [bodyDic allKeys].count > 0) {
        NSArray *keyArray = [bodyDic allKeys];
        NSArray *valueArray = [bodyDic allValues];
        for(int i=0;i<keyArray.count;i++)
        {
            [bodyStr appendFormat:@"%@=%@",keyArray[i],valueArray[i]];
            if(i<keyArray.count-1)
            {
                [bodyStr appendString:@"&"];
            }
        }
    }
    
    
    
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //设置请求方式
    [mutableRequest setHTTPMethod:@"POST"];
    //设置请求头
    [mutableRequest setAllHTTPHeaderFields:requestHeaders];
    //设置请求体
    [mutableRequest setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 3 处理请求得到的结果
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    NSString *responseString =  nil;
    NSString *statusString = nil;
    NSString *httpCodeString;
    NSString *msgString = nil;
    NSError *error = nil;
    NSURLResponse *response = nil;
    //同步方式进行请求 
    NSData *data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
    if (error) {//post 请求失败
        statusString = @"-1";
        httpCodeString = [NSString stringWithFormat:@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]];
        msgString = error.localizedDescription;
        if (data == nil) {
            responseString = @"";
        }
        else {// post请求成功
            responseString = (NSString *)data;
        }
        
    }
    else {
        statusString = @"0";
        httpCodeString = [NSString stringWithFormat:@"%ld",(long)[(NSHTTPURLResponse *)response statusCode]];
        msgString = @"";
        responseString = (NSString *)data;
    }
    [resultDic setValue:statusString forKey:@"status"];
    [resultDic setValue:msgString forKey:@"msg"];
    [resultDic setValue:httpCodeString forKey:@"http_code"];
    [resultDic setValue:responseString forKey:@"response"];
    // 4 将resultDic转成JSON字符串
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *resultString = [writer stringWithObject:resultDic];
    // 5 回调给JS
    if (responseCallBack != nil) {
        responseCallBack (resultString);
    }
    
    
    
    
    
    
}


@end
