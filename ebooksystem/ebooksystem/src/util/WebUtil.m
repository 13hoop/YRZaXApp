//
//  WebUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "WebUtil.h"

#import "Config.h"

#import "LogUtil.h"


@implementation WebUtil

#pragma mark - methods

+ (BOOL)checkUserAgent {
    NSString *originalUserAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    NSString *newUserAgent = [[NSString alloc] initWithFormat:@"%@ %@", originalUserAgent, [Config instance].webConfig.userAgent];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : newUserAgent, @"User-Agent" : newUserAgent}];
    
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    
    return YES;
}


/**
 * quest
 *
 * url:请求地址
 * verb:请求方式
 * parameters:请求参数
 */
+ (NSString *)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withHeader:(NSDictionary *)headers andData:(NSDictionary *)data {
    NSString *responseStr = nil;
    NSData *body = nil;
    NSMutableString *params = nil;
    NSString *contentType = @"text/html; charset=utf-8";
    NSURL *finalURL = url;
    
    // params
    if(nil != data){
        params = [[NSMutableString alloc] init];
        for(id key in data){
            NSString *encodedkey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *encodedValue = [[data objectForKey:key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@";/?@&=+$" ]];
//            NSString *encodedValue = [[data objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            LogDebug(@"==== >cur key: %@, cur value: %@", key, [data objectForKey:key]);
            
            //url编码的方法有bug：会导致内存溢出
//            CFStringRef value = (__bridge CFStringRef)[[data objectForKey:key] copy];
//           
//            CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, value, NULL, (CFStringRef)@";/?:@&=+$", kCFStringEncodingUTF8);
//            CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, value, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);

            [params appendFormat:@"%@=%@&", encodedkey, encodedValue];
            
            //            CFRelease(value); // comment out to avoid error: CFString release]: message sent to deallocated instance
//            CFRelease(encodedValue);
        }
        [params deleteCharactersInRange:NSMakeRange([params length] - 1, 1)];
    }
    
    // post
    if ([verb caseInsensitiveCompare:@"post"] == NSOrderedSame) {
        contentType = @"application/x-www-form-urlencoded; charset=utf-8";
        body = [params dataUsingEncoding:NSUTF8StringEncoding];
    }
    // get
    else {
        if(nil != data){
            NSString *urlWithParams = [[url absoluteString] stringByAppendingFormat:@"?%@", params];
            finalURL = [NSURL URLWithString:urlWithParams];
        }
    }
    
    // headers
    NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] init];
    [requestHeaders setValue:contentType forKey:@"Content-Type"];
    [requestHeaders setValue:@"text/html" forKey:@"Accept"];
    [requestHeaders setValue:@"no-cache" forKey:@"Cache-Control"];
    [requestHeaders setValue:@"no-cache" forKey:@"Pragma"];
    [requestHeaders setValue:@"close" forKey:@"Connection"];
    if (nil != headers) {
        NSString *userAgent = [headers objectForKey:@"user_agent"];
        if (userAgent != nil && userAgent.length > 0) {
            [requestHeaders setValue:userAgent forKey:@"User-Agent"];
        }
    }
    
    // request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0]; // 60s
    [request setHTTPMethod:verb];
    [request setAllHTTPHeaderFields:requestHeaders];
    if (nil != data) {
        [request setHTTPBody:body];
    }
    params = nil;
    
    // response
    NSURLResponse *response;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        LogError(@"something is wrong: %@", [error description]);
    }
    else {
        if (responseData) {
            responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        }
    }
    
    return  responseStr;
}

@end
