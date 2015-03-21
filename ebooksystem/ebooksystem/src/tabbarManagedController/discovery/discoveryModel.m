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
#import "KnowledgeManager.h"
#import "KnowledgeDownloadManager.h"
#import "PathUtil.h"
#import "IADownloadManager.h"

@implementation discoveryModel

- (BOOL)getBookInfoWithDataIds:(NSArray *)dataIds {
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //data
    NSMutableArray *arr = [[NSMutableArray alloc] init];// [NSMutableArray array];
    if (dataIds == nil || dataIds.count <= 0) {
        return;
    }
    //js掉native接口传一个字符串参数
    for (NSString *bookId in dataIds) {
        if (bookId == nil) {
            continue;
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:bookId forKey:@"data_id"];
        [dic setValue:@"" forKey:@"data_version"];
        
        [arr addObject:dic];
        
    }
    
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
    [data setValue:@"" forKey:@"g_user_id"];
    
    
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
        [data setValue:jsonOfDataUpdateRequestInfo forKey:@"data"];
    }
    
    
    // 发送web请求, 获取响应
    NSURL *url = [NSURL URLWithString:@"http://www.zaxue100.com/index.php?c=book_meta_ctrl&m=get_book_meta"];
    NSString *serverResponseStr = [WebUtil sendRequestTo:url usingVerb:@"POST" withHeader:headers andData:data];
    if (serverResponseStr == nil || serverResponseStr.length <= 0) {
        LogError(@"[discoveryModel - getBookInfoWithDataIds]: request failed ,serverResponseStr is  equal to nil ");
        return;
    }
    //解析获取到的服务器响应信息
    BOOL success = [self parseServerResponse:serverResponseStr];
        if (!success) {
            LogError (@"[discoverModel - getBookInfoWithDataIds ]: parseServerResponse failed ");
            return;
        }
    });
    return YES;
}

//解析服务器返回的响应，并下载试读书
- (BOOL)parseServerResponse:(NSString *)responseStr {
    if (responseStr == nil || responseStr.length <= 0) {
        LogDebug(@"discoverModel -- parseServerResponse: server responseStr is equal to nil");

        return  NO;
    }
    SBJsonParser *parse = [[SBJsonParser alloc] init];
    NSDictionary *responseDic = [parse objectWithString:responseStr];
    //parse data key matching the value  :
   NSString *dataStr = [responseDic objectForKey:@"data"];
    //get data_id
    NSArray *dataArr = [parse objectWithString:dataStr];
    if (dataArr == nil || dataArr.count <= 0 ) {
        LogDebug(@"discoverModel -- parseServerResponse: dataArr is nil");
        return NO;
    }
    for (NSDictionary *dic  in dataArr) {
        if (dic == nil) {
            continue;
        }
        NSString *bookId = [dic objectForKey:@"data_id"];
        //1 将data对应的数据存储到数据库中
        [[KnowledgeManager instance] registerBookMetaInfo:dic];
        //2 下载封面图片
        [self coverImageFileOperation:dic];
        //3 下载试读书
        [[KnowledgeManager instance] startDownloadDataManagerWithDataId:bookId];
        }
    
    return YES;
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

- (BOOL)coverImageFileOperation:(NSDictionary *)dic {
    
    NSString *coverImageStr = [dic objectForKey:@"cover_src"];
    NSString *bookId = [dic objectForKey:@"data_id"];
    NSURL *coverUrl = [NSURL URLWithString:coverImageStr];
    NSString *lastPartMent = [coverUrl lastPathComponent];//图片名
    NSString *extension = [[lastPartMent componentsSeparatedByString:@"."] lastObject];//图片拓展名 png jpg
    NSString *insideSandBoxPath = [NSString stringWithFormat:@"knowledge_data/coverImage/%@/%@",bookId,lastPartMent];
    NSString *downloadRootPath = [PathUtil getDocumentsPath];
    //coverImage的保存路径
    NSString *savePath = [NSString stringWithFormat:@"%@/%@", downloadRootPath, insideSandBoxPath];
    LogDebug(@"下载目录是======%@",savePath);
    
    // 3 下载,
    //        [KnowledgeDownloadManager instance].delegate = self;
    
    if (coverImageStr == nil || savePath ==nil) {
        LogInfo(@"discoveryModel - parseServerResponse : coverImageStr or savePath is nil");
        return NO;
    }
    // 4 移除旧的封面图片
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit =[fileManager fileExistsAtPath:savePath];
    if (isExit) {
        //移除旧的封面图片
        BOOL isRemoved =  [fileManager removeItemAtPath:savePath error:nil];
        if (!isRemoved) {
            LogInfo(@"discoverModel - parseServerRes:remove  old cover image failed");
        }
    }
    BOOL isDir;

    NSString *pathTest = [savePath stringByDeletingLastPathComponent];
    NSLog(@"path =====%@",pathTest);
    BOOL exit = [fileManager fileExistsAtPath:pathTest isDirectory:&isDir];
    if (!isDir || !exit) {
        [fileManager createDirectoryAtPath:pathTest withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    BOOL isSuccess = [[KnowledgeDownloadManager instance] startDownloadWithTitle:bookId andDesc:@"封面图片" andDownloadUrl:coverUrl andSavePath:savePath andTag:nil];
    
    BOOL succeeded = [[KnowledgeDownloadManager instance] directDownloadWithUrl: coverUrl andSavePath: savePath];
    NSLog(@"====%@",savePath);
    BOOL ret = [fileManager fileExistsAtPath:savePath];
    
    return ret;
}


@end
