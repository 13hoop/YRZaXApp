//
//  ResetUserAgentUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-20.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "ResetUserAgentUtil.h"

@implementation ResetUserAgentUtil

+(BOOL)resetUserAgent
{
    NSString *oldUserAgentStr=[[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *example=@"ZAXUE_IOS_POLITICS_APP";
    NSString *ua = [[NSString alloc] initWithFormat:@"%@ %@",oldUserAgentStr,example];
    NSMutableDictionary *uaDictionary= [NSMutableDictionary dictionaryWithObjectsAndKeys:ua, @"UserAgent", nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:uaDictionary];
    
    return YES;
}

@end
