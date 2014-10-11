//
//  KnowledgeDataManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataManager.h"

#import "Config.h"

#import "KnowledgeMetaEntity.h"


#import "UserManager.h"

#import "PathUtil.h"
#import "DeviceUtil.h"
#import "MD5Util.h"
#import "CryptUtil.h"
#import "WebUtil.h"
#import "SecurityUtil.h"



@implementation KnowledgeDataManager

#pragma mark - properties
@synthesize lastError;



#pragma mark - singleton
+ (KnowledgeDataManager *)instance {
    static KnowledgeDataManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[KnowledgeDataManager alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - knowledge data operations
#pragma mark - copy data files
// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData {
    NSString *knowledgeDataRootPathInAssets = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    
    BOOL ret = [PathUtil copyFilesFromPath:(NSString *)knowledgeDataRootPathInAssets toPath:(NSString *)knowledgeDataRootPathInDocuments];
    
    return ret;
}

// load knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeMetaEntity *)knowledgeMetaEntity {
    if (knowledgeMetaEntity == nil || knowledgeMetaEntity.dataPath == nil || knowledgeMetaEntity.dataPath.length <= 0) {
        return nil;
    }
    
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@/%@", knowledgeDataRootPathInDocuments, knowledgeMetaEntity.dataPath, @"data.json"];
        
    // read file line by line
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
    if (fileContents == nil || fileContents.length <= 0) {
        NSLog(@"[KnowledgeDataManager::loadKnowledgeData()] failed, data id: %@, file: %@, error: %@", knowledgeMetaEntity.dataId, fullFilePath, error.localizedDescription);
        return nil;
    }
    
    return fileContents;
}

#pragma mark - download knowledge data
// start downloading
- (BOOL)startDownloadData:(NSString *)dataId {
    // 启动后台任务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. 获取该data对应的download_url
        ServerResponseOfKnowledgeData *response = [self getDataDownloadInfo:dataId];
        if (response == nil) {
            return;
        }
        // 2. 启动后台下载任务, 将data pack下载至本地
        
        // 3. 解包
        // 4. 拷贝文件, 更新数据库
        // 5. 返回
    });
    
    return YES;
}

// get download info
- (ServerResponseOfKnowledgeData *)getDataDownloadInfo:(NSString *)dataId {
    lastError = @"";
    
    UserInfo *curUserInfo = [[UserManager instance] getCurUser];
    if (curUserInfo == nil || curUserInfo.username == nil) {
        lastError = @"用户信息不完整, 请确认用户已成功登录";
        return nil;
    }
    
    // crypt
    NSString *secretKey = [MD5Util md5ForString:curUserInfo.password];
    NSString *iv = [MD5Util md5ForString:secretKey];
    CryptUtil *cryptUtil = [[CryptUtil alloc] initWithKey:secretKey andIV:iv];
    
    // Url
    NSString *url = [Config instance].knowledgeDataConfig.dataUrlForDownload;
    
    // headers
    NSString *userAgent = [Config instance].webConfig.userAgent;
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:userAgent forKey:@"user_agent"];
    
    // body params
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    [data setValue:userAgent forKey:@"user_agent"];
    [data setValue:@"2" forKey:@"encrypt_method"]; // 对称加密
    [data setValue:@"3" forKey:@"encrypt_key_type"];
    
    [data setValue:curUserInfo.username forKey:@"user_name"];
    
    // device id
    {
        NSString *deviceId = [DeviceUtil getVendorId];
        [data setValue:deviceId forKey:@"device_id"];
    }
    
    // param data
    {
        // 待加密信息
        DataDownloadRequestInfo *dataDownloadRequestInfo = [[DataDownloadRequestInfo alloc] init];
        dataDownloadRequestInfo.dataId = dataId;
        NSString *jsonOfDataDownloadRequestInfo = [dataDownloadRequestInfo toJSONString];
        
        // 对称加密
        NSString *encryptedContent = [cryptUtil encryptAES128:jsonOfDataDownloadRequestInfo];
        if (encryptedContent == nil || encryptedContent.length <= 0) {
            lastError = @"数据加密失败";
            return nil;
        }
        
        [data setValue:encryptedContent forKey:@"data"];
    }
    
    // 发送web请求, 获取响应
    NSString *serverResponseStr = [WebUtil sendRequestTo:[NSURL URLWithString:url] usingVerb:@"POST" withHeader:headers andData:data];
    if (serverResponseStr == nil || serverResponseStr.length <= 0) {
        lastError = @"网络请求失败";
        return nil;
    }
    
    // 解析响应: json=>obj
    NSError *error = nil;
    ServerResponseOfKnowledgeData *response = [[ServerResponseOfKnowledgeData alloc] initWithString:serverResponseStr error:&error];
    if (response == nil || response.data == nil
        || response.data.length <= 0) {
        lastError = @"服务器响应数据异常";
        return nil;
    }
    
    // 解析加密后的数据字段
    NSString *decryptedContent = nil;
    if (response.encryptMethod == 2) {
        if (response.encryptKeyType == 3) {
            NSString *encryptedData = [response.data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // 对称解密
            decryptedContent = [cryptUtil decryptAES128:encryptedData];
        }
    }
    
    if (decryptedContent == nil || decryptedContent.length <= 0) {
        lastError = @"数据解析失败";
        return nil;
    }
    
    // trim: 去除尾的\0. 否则json解析时会失败.
    decryptedContent = [decryptedContent stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    if (decryptedContent == nil || decryptedContent.length <= 0) {
        lastError = @"服务器返回数据为空";
        return nil;
    }
    
    // 解析dataInfo: json=>obj
    response.dataInfo = [[ServerResponseDataInfo alloc] initWithString:decryptedContent error:&error];
    if (response.dataInfo == nil) {
        lastError = @"服务器返回数据解析失败";
        NSLog(@"error: %@", error.localizedDescription);
        return nil;
    }
    
    // 检查服务器返回状态
    if (response.dataInfo.status != 0) {
        lastError = response.dataInfo.message;
        return nil;
    }
    
    return response;
}

@end
