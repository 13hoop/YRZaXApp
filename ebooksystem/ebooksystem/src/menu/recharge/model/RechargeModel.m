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

#import "LogUtil.h"


@implementation RechargeModel

-(void)getRecharge:(NSString *)cardID
{
    dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(t, ^{
        
        
        //将object对象转成json
        SBJsonWriter *jsonWriter=[[SBJsonWriter alloc] init];
        NSError *error;
        //kmlin b
        LogDebug(@"cardID===%@",cardID);
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"user_name",cardID,@"card_id",@"1",@"recharge_type",nil];
        NSString *jsonString=[jsonWriter stringWithObject:dic error:&error];
        LogDebug(@"jsonString==%@",jsonString);
        NSString *string=[SecurityUtil AES128Encrypt:jsonString andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
//        NSString *string=[SecurityUtil encryptAESData:jsonString app_key:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
        LogDebug(@"加密后的数据是：%@",string);
        LogDebug(@"看一下能否打印出来设备的ID %@",[[UIDevice currentDevice] uniqueDeviceIdentifier]);
        //发起网络请求
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]
        /*
         
         
         Hash{
         “encrypt_method”=>”2”,  #对称加密
         “encrypt_key_type”=>”3”，#cookie-token，暂时使用用户密码
         “user_name”=>”kmlin”,
         “device_id”=>””, #设备ID
         “data”=>json{
         Hash{
         “user_name”=>”kmlin”, #用户名不允许修改
         “card_id”=>””, #充值卡ID号
         }
         }, 
         }
         */
        
        NSDictionary *parameter=@{@"encrypt_method":@"2",@"encrypt_key_type":@"3",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":[[UIDevice currentDevice] uniqueDeviceIdentifier],@"data":string};
        [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=chargectrl&m=recharge" parameters:parameter success:^(AFHTTPRequestOperation *operation ,id responseobject){
            NSDictionary *dic=responseobject;
            
            NSString *dataStr=dic[@"data"];
            NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
            LogDebug(@"message===%@",data[@"msg"]);
            
            //
            [self.recharge_delegate getRechargeMessage:data[@"msg"]];
            
        } failure:^(AFHTTPRequestOperation *operation,NSError *error){
            LogError(@"请求失败, error: %@", error.localizedDescription);
        }];

    });
    
}

@end
