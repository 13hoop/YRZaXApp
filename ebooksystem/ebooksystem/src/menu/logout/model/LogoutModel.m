//
//  LogoutModel.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-7.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "LogoutModel.h"

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

#import "LogUtil.h"


@implementation LogoutModel


-(void)logout
{
    LogDebug(@"告诉服务器，我要退出");
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    //使用最新版的AFNetworking发起get和post请求需要指定响应的类型，也就是下面这句话。
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=logout" parameters:nil success:^(AFHTTPRequestOperation *operation ,id responseobject){
        NSDictionary *dic=responseobject;
        
        LogDebug(@"dic=====%@",dic);
        
        NSString *dataStr=dic[@"data"];
        NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
        //
        [self.logout_delegate logoutMessage:data[@"msg"]];
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        LogError(@"请求失败, error: %@", error.localizedDescription);
    }];
    
}
@end
