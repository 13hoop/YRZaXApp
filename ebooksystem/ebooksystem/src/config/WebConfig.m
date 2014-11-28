//
//  WebConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "WebConfig.h"

@implementation WebConfig

@synthesize userAgent = _userAgent;


#pragma mark - properties
// web request params
- (NSString *)userAgent {
    return @"com.diyebook.ebooksystem.app.ios";
}

#pragma mark - methods
// singleton
+ (WebConfig *)instance {
    static WebConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
