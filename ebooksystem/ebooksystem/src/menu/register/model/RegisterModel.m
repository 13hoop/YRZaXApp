//
//  RegisterModel.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-3.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "RegisterModel.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "CRSA.h"
#import "SBJson.h"
#import "UIDevice+IdentifierAddition.h"
#import "DeviceUtil.h"
@interface RegisterModel()

@property(nonatomic,strong)RegisterUserInfo *userInfo;

@end



@implementation RegisterModel
//get userInfo
-(void)getUserInfo:(RegisterUserInfo *)userInfo
{
    self.userInfo=userInfo;
    
    
    
}

-(void)getPublickey
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];    
    [manager GET:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=get_public_key" parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSDictionary *dic=responseObject;
       //get string
        NSString *jsonStr=dic[@"data"];
        NSData *jsonData=[jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *data=[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSString *public_key=data[@"public_key"];
        [self createPublickeyPemWithString:public_key];
       
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@
                            "网络状况不佳，请检查您的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重试", nil];
        [alert show];
    }];
}
//create pem file
-(void)createPublickeyPemWithString:(NSString *)publicKeyString
{
    CRSA *crsa=[CRSA shareInstance];
    [crsa generatersa_public_keyWithpublicString:publicKeyString];
    BOOL isfind =[crsa importRSAKeyWithType:KeyTypePublic];
    NSLog(@"fina publicKey==%hhd",isfind);
    [self encryptByRsa];
    
}
-(void)encryptByRsa
{
    CRSA *crsa=[CRSA shareInstance];
    NSDictionary *userInfoDic=@{@"user_name":self.userInfo.userName,@"pwd":self.userInfo.passWord,@"email":self.userInfo.email};
    
    SBJsonWriter *jsonWriter=[[SBJsonWriter alloc] init];
    NSError *error;
    NSString *jsonString=[jsonWriter stringWithObject:userInfoDic error:&error];
    
    NSString *encodeString=[crsa encryptByRsa:jsonString withKeyType:KeyTypePublic];
    NSLog(@"encodeString=====%@",encodeString);
    //decrypt for test
    NSString *decodeString=[crsa decryptByRsa:encodeString withKeyType:KeyTypePrivate];
    NSLog(@"decodeString======%@",decodeString);
    [self getRegisterResult:encodeString];
    
    
}
-(void)getRegisterResult:(NSString *)jsonString
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *parameter=@{@"encrypt_method":@"1",@"encrypt_key_type":@"1",@"user_name":self.userInfo.userName,@"device_id":[DeviceUtil getVendorId],@"data":jsonString};
    [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=register" parameters:parameter success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSDictionary *dic=responseObject;
        NSString *dataStr=dic[@"data"];
        NSData *data=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:0];
        [self.register_delegate registerMessage:dataDic anduserInfo:self.userInfo];
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@
                            "网络状况不佳，请检查您的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"重试", nil];
        [alert show];
    }];

}
@end
