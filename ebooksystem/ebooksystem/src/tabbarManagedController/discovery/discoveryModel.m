//
//  discoveryModel.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/25.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "discoveryModel.h"
#import "AFNetworking.h"
#import "LogUtil.h"
#import "SBJson.h"
#import "AppUtil.h"
#import "Config.h"
#import "WebUtil.h"

@implementation discoveryModel

- (NSDictionary *)getBookInfoWithDataIds:(NSArray *)dataIds {
    
    
    //appversion
   NSString *appVersion = [NSString stringWithFormat:@"%@",[AppUtil getAppVersionStr]];
    //data
    NSMutableArray *arr = [NSMutableArray array];
    if (dataIds == nil || dataIds.count <= 0) {
        return nil;
    }
    
    //先默认传给我一个字符串
    for (NSString *bookId in dataIds) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if (bookId == nil) {
            continue;
        }
        [dic setValue:bookId forKey:@"data_id"];
        [dic setValue:@"0.0.0.0" forKey:@"data_version"];
        [arr addObject:dic];
        
    }
     /*
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *dataJsonString = [writer stringWithObject:arr];
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *parameter=@{@"encrypt_method":@"0",@"encrypt_key_type":@"0",@"g_user_id":@"",@"app_platform":@"1",@"app_version":appVersion,@"data":dataJsonString};
    
    [manager POST:@"http://test.zaxue100.com/index.php?c=Info_desk_ctrl&m=get_book_meta" parameters:parameter success:^(AFHTTPRequestOperation *operation,id responsrObject){
        NSDictionary *dic=responsrObject;
        LogDebug(@"获取用户信息返回的字典dic=====%@", dic);
        //服务器返回的是一个字符串
        NSString *jsonStr= nil;
        
        jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        NSString *stra=[self JSONString:jsonStr];
        SBJsonParser *parser=[[SBJsonParser alloc] init];
        NSDictionary *responseDic = [parser objectWithString:responsrObject];
        NSLog(@"获取书籍信息为====%@",responseDic);
        //储存用户的邮箱
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        LogDebug(@"网络请求失败");
        NSLog(@"errpr====%@",error);
    }];
*/
    
    
    
    
    

    
    // headers
    NSString *userAgent = [Config instance].webConfig.userAgent;
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:userAgent forKey:@"user_agent"];
    
    // body params --2.0中post请求体中的参数修改了部分内容。
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    //    [data setValue:userAgent forKey:@"user_agent"];
    [data setValue:@"0" forKey:@"encrypt_method"]; // 对称加密
    [data setValue:@"0" forKey:@"encrypt_key_type"];
    [data setValue:@"1" forKey:@"app_platform"]; // ios
    [data setValue:nil forKey:@"g_user_id"];
    
    
    
    {
        NSString *appVersion = [NSString stringWithFormat:@"%@",[AppUtil getAppVersionStr]];
        [data setValue:appVersion forKey:@"app_version"]; // app version
    }
    // param data
    {
        // 待加密信息
        NSMutableString *jsonOfDataUpdateRequestInfo = [[NSMutableString alloc] init];
        [jsonOfDataUpdateRequestInfo appendString:@"["];
        
        BOOL isFirst = YES;
        for (id obj in arr) {
            //修改了dataInfo，易出错点
            
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *json = [writer stringWithObject:obj];
            
            NSLog(@"warning -- 易出错点:knowledgeDataManager - getDataUpdataInfo:%@",json);
            if (json == nil || json.length <= 0) {
                continue;
            }
            
            if (isFirst) {
                isFirst = NO;
            }
            else {
                [jsonOfDataUpdateRequestInfo appendString:@","];
            }
            
            [jsonOfDataUpdateRequestInfo appendString:json];
        }
        
        [jsonOfDataUpdateRequestInfo appendString:@"]"];
        
        LogDebug(@"[KnowledgeDataManager-getDataUpdateInfo -- look is json String:] encryptedContent: %@", jsonOfDataUpdateRequestInfo);
        //        [data setValue:encryptedContent forKey:@"data"];
        //data对应的需要是一个json字符串，浩哥上述操作是拼接了一个json格式的字符串
        [data setValue:jsonOfDataUpdateRequestInfo forKey:@"data"];
        NSLog(@"发给server的json======%@",jsonOfDataUpdateRequestInfo);
    }
    
    
    // 发送web请求, 获取响应
    NSURL *url = [NSURL URLWithString:@"http://test.zaxue100.com/index.php?c=Info_desk_ctrl&m=get_book_meta"];
    NSString *serverResponseStr = [WebUtil sendRequestTo:url usingVerb:@"POST" withHeader:headers andData:data];
    if (serverResponseStr == nil || serverResponseStr.length <= 0) {
        return nil;
    }
    NSLog(@"%@",serverResponseStr);
    
    
    
    

    return nil;
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

//保存到数据库

@end
