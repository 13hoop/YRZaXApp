//
//  PaymentConfig.m
//  ebooksystem
//
//  Created by zhenghao on 11/27/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "PaymentConfig.h"

@implementation PaymentConfig

@synthesize urlForAliPayViaWeb = _urlForAliPayViaWeb;

#pragma mark - properties
// 支付宝网页支付的url
- (NSString *)urlForAliPayViaWeb {
    return @"http://118.244.235.155:8296/alipay/wap/php/index.php";
}

#pragma mark - methods
// singleton
+ (PaymentConfig *)instance {
    static PaymentConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
