//
//  AliPayViewController.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-25.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "AliPayViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AliPayManager.h"

@interface AliPayViewController ()

@end

@implementation AliPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self createRechargeButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark alipay
#pragma mark create Button
-(void)createRechargeButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 40, 100, 40);
    [btn setTitle:@"购买" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(charge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
#pragma mark 支付宝支付
-(void)charge:(UIButton *)btn
{
//    [self getValue];
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:@"二十天二十题",@"tradeNo",@"测试专用",@"productDescription",[NSString stringWithFormat:@"%.2f", 0.01],@"amount",@"http://118.244.235.155:8296/alipay_notify.php",@"notifyURL",[self generateTradeNO],@"tradeNo", nil];
    [self purchaseOrder:dic];
}

#pragma mark 创造数据
//
//-(void)getValue
//{
//    /*============================================================================*/
//    /*=======================需要填写商户app申请的===================================*/
//    /*============================================================================*/
////    NSString *partner = @"2088511933544308";
////    NSString *seller = @"yingtehua8@sina.com";
//    //私钥是支付宝给的，还是自己生成的？
////    NSString *privateKey=@"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAL0M8jaJCm9bMb7PjgI0wR9+mpzWTcNTwTyYBEXmrJg3MjRVluUezDjQhQBSrgaMTeM40cz+1Nt/f1OlS/vB9PzGSF+MDty6zS0NQEEvVjUUge7PsOtbPDIEmuPppKIj4wETfavaZt7j4/kVuABDC2P1DpPRP686dJsNTkSO5qrNAgMBAAECgYApxEVy9P3gMkagQFzAcgVEvwTLp7EQeV2U1IUFKHxzOKaX11z6C77UwoTP2HRoL/E5RSFc5+QBBn8L7NYHrgdAu4L5Kl048saM53QyXJviQs7lgxDSBbo+EHDY9OJJsVRalpqKSirgBZmce/M4/tNhDxUfV5yXvxOC43JEr92UIQJBAPXbahDDMN+D0MqG1y0zPyU5bJwopXsSLIxpqp4vRmHokMxlber5HGMgSSnVQ9x9j974G1RSamqV34xwnqPzIlUCQQDE2ZPgtKd9Te19kGpmmCs64iqlkUVabAuKI8wMyx4hGZx6/EpeufFiTpF3F3YDN37JOenBefLL9UIkrOrjXI6ZAkBmpX75FKV5DG3FwNph0r2QaxM/d3DvmzziOtOzS4WVJyYdUFO+ANerQzWIs7OrgPjqXKf8YpRvf7dfyT1SshYpAkAhj0qDw6jOVwvHHWjWZtjv6AEHSxX8zXDGM0YlZDeVww0Hdp2jOqYpcWWhXRGUiNCHs+TjREwdc4m8QPKmom/5AkAYGRw6TLB/XWfEvlGLMHMmbZWMXDBdBmlIN+JK2oRjIoTryG35KlXzAHWcAq2xVhvCd6gJjz9arUmqewOLBMWn";
//    
//    
//    NSString *partner = @"2088611384912771";
//    NSString *seller = @"swsk@diyebook.cn";
//    NSString *privateKeyPKCS8 = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALXAMPEGd/tT9KfuAJeWUG7wz+lXu/J/8WtStx9v4BTlLBdQPjDK3fQ/vmTvQRnu7wjHZwExCDXb1SJ/Q93lRf/ob4hI2jc2dQXTUV1xSydNBPtkIgFg69jjBiy++jHmpsA0OEA8HJLiFdVYfqP0apgPfMu9ikL1ZAH6XZ5kPei3AgMBAAECgYBwmu63piZYFKAUGyVKxdp3ocNu8uiDSjmtIMZMN+hBietTVmfxmv8BAS1ZI9LV2m9GpSRwXIyVsenPQcIujIpdAnsCGkv4HiKsCrEKbR3c/YHZ716G5bd6354g0b3Dak1FH5Ib8DOVlMR4HxG5X7BNeZSliHuRrsA5IZkkJgR2gQJBAO3ICQxxSukKC5qJKHqDx8IRazKjBalnv2+YBQxElVeziDnMOafv1UB1vUprpB6ZyGtV0zsTjmaCUEJuwUDQB8cCQQDDrSR2wQYQKwh2SOsotgJWLMoDZHavINU9GhJQIvRlfENsI+BuzY1ig5c2ihTiY7SenahoBuuSYASTx5Ym1HeRAkEAkM/3us0wqxaEFJydu2eQe7+yAofIRfC6ZRM3V85ZCa18NH8NShrFTFmoa698p2pO5hfB6kOxwPpyONNM/NT1NwJAS/jccHMPDJX4qhwzmVHZZGXtZRXLcsFXqWqG87AunXx6nPDtAXgzTa1zt0wzQZaemPrzWLhfHCzFei8CoD7b0QJAci2QoNept5RYPoUywdyFCPYRyS+edF3PwmZrLKM8FAiZKKEllQr0xP7Jki3Mfkh3QtqsHkSopuYzxdel2jGEPQ==";
//    
//    /*============================================================================*/
//    /*============================================================================*/
//    /*============================================================================*/
//    Order *order = [[Order alloc] init];
//    order.partner = partner;
//    order.seller = seller;
//    order.tradeNO = [self generateTradeNO]; // 订单ID（由商家自行制定）
//    order.productName = @"打劫"; // 商品标题
//    order.productDescription = @"此商品有深意，胆小怕事者请勿购买"; // 商品描述
//    order.amount = [NSString stringWithFormat:@"%.2f", 0.01]; // 商品价格
//    order.notifyURL =  @"http://118.244.235.155:8296/alipay_notify.php"; // 回调URL
//    
//    order.service = @"mobile.securitypay.pay";
//    order.paymentType = @"1";
//    order.inputCharset = @"utf-8";
//    order.itBPay = @"30m";
//    
//    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types(这个字段设置是为了什么？？)
////    NSString *appScheme = @"ebooksystem_politics_alipay";
//    NSString *appScheme=@"ebooksystemPoliticsAlipay";
//    
//    //将商品信息拼接成字符串
//    NSString *orderSpec = [order description];
//    NSLog(@"商品订单描述信息:orderSpec = %@", orderSpec);
//    ////获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//    id<DataSigner> signer = CreateRSADataSigner(privateKeyPKCS8);
//    NSString *signedString = [signer signString:orderSpec];
//    NSString *orderString = nil;
//    if (signedString != nil) {
//        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//                       orderSpec, signedString, @"RSA"];
//        
//        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            NSLog(@"reslut = %@",resultDic);
//        }];
//        
//    }
//    
//}

#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));//srand使用：为了保证每次生成的订单编号是唯一的。
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

#pragma mark alipaymanager 
-(void)purchaseOrder:(NSDictionary *)purchaseDic
{
   

    
    NSString *tradeNo=[self generateTradeNO];
    NSString *productName=@"地瓜";
    NSString *productDescription=@"土豆别称地瓜";
    NSString *amount=[NSString stringWithFormat:@"%.2f", 0.01];

    //调用支付宝支付方法
    AliPayManager *manager=[AliPayManager instance];
    [manager paymentWithTradeNO:tradeNo productName:productName productDescription:productDescription amount:amount];
    
}

@end
