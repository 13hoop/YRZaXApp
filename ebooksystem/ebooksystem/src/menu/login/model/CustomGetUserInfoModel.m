//
//  CustomGetUserInfoModel.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-9.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomGetUserInfoModel.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

#import "GTMBase64.h"
#import "NSString+Hashing.h"
#import "UIDevice+IdentifierAddition.h"
#import "SBJson.h"

#import "SecurityUtil.h"
#import "DeviceUtil.h"
#import "LogUtil.h"


@implementation CustomGetUserInfoModel


-(void)getUserInfo
{
    //再次发起网络请求,获取用户的余额信息
    NSString *device_id=[DeviceUtil getVendorId];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *parameter=@{@"encrypt_method":@"0",@"encrypt_key_type":@"0",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":device_id};
    
    [manager POST:@"http://zaxue100.com/index.php?c=passportctrl&m=get_user_info" parameters:parameter success:^(AFHTTPRequestOperation *operation,id responsrObject){
        NSDictionary *dic=responsrObject;
        LogDebug(@"获取用户信息返回的字典dic=====%@", dic);
        
        NSString *dataStr=dic[@"data"];
        //服务器返回的是一个字符串，需要先将这个字符串解密，转成json字符串，再将json字符串转成字典
        NSString *jsonStr=[SecurityUtil AES128Decrypt:dataStr andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
        LogDebug(@"解密后的字符串是%@",jsonStr);
        
        jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        NSString *stra=[self JSONString:jsonStr];
        SBJsonParser *parser=[[SBJsonParser alloc] init];
        NSDictionary *data=[parser objectWithString:stra];
        NSString *surplus_score=data[@"surplus_score"];
        //储存用户的邮箱
        [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoEmail"];
        [self.userInfo_delegate getUserinfo:surplus_score];
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        LogDebug(@"登陆失败");
    }];
                   
}
-(NSString *)JSONString:(NSString *)aString {
    NSMutableString *s = [NSMutableString stringWithString:aString];
    //[s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

@end
