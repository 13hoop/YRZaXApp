//
//  PaymentConfig.h
//  ebooksystem
//
//  Created by zhenghao on 11/27/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentConfig : NSObject

#pragma mark - properties
// 支付宝网页支付的url
@property(nonatomic, copy, readonly) NSString *urlForAliPayViaWeb;


#pragma mark - methods
// singleton
+ (PaymentConfig *)instance;

@end
