//
//  RechargeModel.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "RechargeModel.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "UIDevice+IdentifierAddition.h"
#import "SBJson.h"
#import "SecurityUtil.h"
#import "DeviceUtil.h"
@implementation RechargeModel

-(void)getRecharge:(NSString *)cardID
{
    dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(t, ^{
        
        
        //将object对象转成json
        SBJsonWriter *jsonWriter=[[SBJsonWriter alloc] init];
        NSError *error;
        //kmlin b
        NSLog(@"cardID===%@",cardID);
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"user_name",cardID,@"card_id",@"1",@"recharge_type",nil];
        NSString *jsonString=[jsonWriter stringWithObject:dic error:&error];
        NSString *string=[SecurityUtil AES128Encrypt:jsonString andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];

        //发起网络请求
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]
        
        
        NSDictionary *parameter=@{@"encrypt_method":@"2",@"encrypt_key_type":@"3",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":[DeviceUtil getVendorId],@"data":string};
        NSLog(@"vendorId====%@",[DeviceUtil getVendorId]);
        
        [manager POST:@"http://zaxue100.com/index.php?c=chargectrl&m=recharge" parameters:parameter success:^(AFHTTPRequestOperation *operation ,id responseobject){
            NSDictionary *dic=responseobject;
            
            NSString *dataStr=dic[@"data"];
            NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
            NSLog(@"message===%@",data[@"msg"]);
           
            
            //
            [self.recharge_delegate getRechargeMessage:data[@"msg"]];
            
        } failure:^(AFHTTPRequestOperation *operation,NSError *error){
            NSLog(@"请求失败");
        }];

    });
    
}

@end
