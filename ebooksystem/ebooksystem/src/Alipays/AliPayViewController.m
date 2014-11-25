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

@interface AliPayViewController ()

@end

@implementation AliPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor orangeColor];
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
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(10, 40, 100, 40);
    [btn setTitle:@"购买" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(charge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
#pragma mark 支付宝支付
-(void)charge:(UIButton *)btn
{
    [self getValue];
}

#pragma mark 创造数据
-(void)getValue
{
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088101568353491";
    NSString *seller = @"2088101568353491";
    //私钥是支付宝给的，还是自己生成的？
    NSString *privateKey =
    @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKcfzYN+td5aBCYUngMZu/i8WUazan7p+yPmiyO8aNZA2HSvbIfeTdx5g+PVqrQ3J9TypxVTtG4ukFn7OwimP+AYN4/5ZUsdYug0DalDhIrUeh6xX6uiS73Vw+m3a5GX5q/YdoIGDJFAY8eJjkqb7cYHnrNUo/9PKkQq+LJzjsCtAgMBAAECgYBbyEN9q+EFtDoDD9+XpFJvUEFXasFZ4fZiyQIxJhANWp+FtbHNDHGGW9XrEjUltATUFk9cjxPQTxJH2ImbPnJlJBXWVCdsxScf8cEYXeAvcQzYT8yPUzXmkdgcs+aZXF9v7XDNbGLL6iYjHqx9mZBivyj1IIr0+wPKLfM9q9BVoQJBAN7HUmgj0qU+sZkRRElr6S4SrvNLuM6D/d6wM7U3sp6sGp6aUk/c1VGSrcaU+fbxxovHBLnzM2IGPiS+O7vlsWsCQQDAC9lZghqpu11KzeQLnjLMCtkXUmAxkuAsWKEKUOkGI8qtw2nxIofjw2gjQQmWmkRzn1GsYup/M5PeEwFWFqRHAkEA1B8yJhrF/bW+YSMBxG9NriL4Fo0pQOqJFjrsYUbReyggiJgkfAqny25ArO85O5tnE7zCkVQyvsl27oF8WyMQVQJAbotjhR5a8rCjNtflGLrrSoBEDiSgsmh1GZG6wRFp0NrxY6xEY0UZK4Xjf8eEGWibVmKyxKP7j1TFHOObtU47KQJAbRxr5A+6bKU8eujxMwEvsZn0t3+sss6K6Vs6rH6EOkDN3vPBqL1sXlp6eZekrt5YDiXFDAsLjju3CKsoRHclBg==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = @"打劫"; //商品标题
    order.productDescription = @"此商品有深意，胆小怕事者请勿购买"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
    order.notifyURL =  @"http://www.zaxue100.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types(这个字段设置是为了什么？？)
    NSString *appScheme = @"ebooksystemAlipay";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"商品订单描述信息:orderSpec = %@",orderSpec);
    ////获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
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


@end
