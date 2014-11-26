//
//  AliPayManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-26.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliPayManager : NSObject
+ (AliPayManager *)instance ;
-(void)paymentWithTradeNO:(NSString*)tradeNO productName:(NSString *)productName productDescription:(NSString *)productDescription amount:(NSString *)amount;
@end
