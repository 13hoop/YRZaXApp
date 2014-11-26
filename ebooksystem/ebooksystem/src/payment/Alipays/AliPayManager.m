//
//  AliPayManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-26.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "AliPayManager.h"
#import "Order.h"
#import "PartnerConfig.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
@implementation AliPayManager
+ (AliPayManager *)instance {
    static AliPayManager *sharedInstance = nil;
    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
        sharedInstance = [[AliPayManager alloc] init];
//    });
    
    return sharedInstance;
    
}
#pragma mark generate Order description && sign
//tradeNO、 productName、 productDescription、 amount、 notifyURL
-(void)paymentWithTradeNO:(NSString*)tradeNO productName:(NSString *)productName productDescription:(NSString *)productDescription amount:(NSString *)amount
{
    Order *order = [[Order alloc] init];
    order.partner =PartnerID;
    order.seller = SellerID;
    order.tradeNO = tradeNO; // 订单ID（由商家自行制定）
    order.productName = productName; // 商品标题
    order.productDescription = productDescription; // 商品描述
    order.amount = amount; // 商品价格
    order.notifyURL = @"http://118.244.235.155:8296/alipay_notify.php";// 回调URL
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types(这个字段设置是为了什么？？设置付款后调回app)
    //    NSString *appScheme = @"ebooksystem_politics_alipay";
    NSString *appScheme=@"ebooksystemPoliticsAlipay";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"商品订单描述信息:orderSpec = %@", orderSpec);
    NSString *privateKeyPKCS8=PrivateKeyPKCS8;
    id<DataSigner> signer = CreateRSADataSigner(privateKeyPKCS8);
    NSString *signedString = [signer signString:orderSpec];
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
       
    }
}


@end
