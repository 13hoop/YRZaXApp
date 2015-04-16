//
//  KnowledgeDataTypes.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataTypes.h"

#pragma mark - AppRequest
@implementation DataDownloadRequestInfo

@synthesize dataId;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"id"]) {
            return @"dataId";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataId"]) {
                                                  return @"id";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end

@implementation DataInfo

@synthesize dataId;
@synthesize curVersion;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"data_id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"data_version"]) {
            return @"curVersion";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataId"]) {
                                                  return @"data_id";
                                              }
                                              else if ([keyName isEqual:@"curVersion"]) {
                                                  return @"data_version";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end

@implementation DataUpdateRequestInfo

@synthesize dataInfo;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"data"]) {
            return @"dataInfo";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataInfo"]) {
                                                  return @"data";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end

#pragma mark -
#pragma mark - ServerResponse
/**
 * 关于data信息的服务器响应
 */
@implementation ServerResponseDataInfo

@synthesize status;
@synthesize message;
@synthesize dataId;
// 数据最新版本号
@synthesize dataVersion;
// 数据下载地址
@synthesize downloadUrl;
// 数据包解密密钥
@synthesize decryptKey;
// 版本说明信息
@synthesize updateInfo;
// 数据发布时间
@synthesize releaseTime;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"msg"]) {
            return @"message";
        }
        else if ([keyName isEqual:@"version"]) {
            return @"dataVersion";
        }
        else if ([keyName isEqual:@"download_url"]) {
            return @"downloadUrl";
        }
        else if ([keyName isEqual:@"data_encrypt_key"]) {
            return @"decryptKey";
        }
        else if ([keyName isEqual:@"update_info"]) {
            return @"updateInfo";
        }
        else if ([keyName isEqual:@"release_time"]) {
            return @"releaseTime";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataId"]) {
                                                  return @"id";
                                              }
                                              else if ([keyName isEqual:@"message"]) {
                                                  return @"msg";
                                              }
                                              else if ([keyName isEqual:@"dataVersion"]) {
                                                  return @"version";
                                              }
                                              else if ([keyName isEqual:@"downloadUrl"]) {
                                                  return @"download_url";
                                              }
                                              else if ([keyName isEqual:@"decryptKey"]) {
                                                  return @"data_encrypt_key";
                                              }
                                              else if ([keyName isEqual:@"updateInfo"]) {
                                                  return @"update_info";
                                              }
                                              else if ([keyName isEqual:@"releaseTime"]) {
                                                  return @"release_time";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end

/**
 * 关于data更新详情的服务器响应
 */
@implementation ServerResponseUpdateInfoDetail

// app是否需要更新
@synthesize needUpdateApp;
// 数据id
@synthesize dataId;
// 数据当前版本号
@synthesize curVersion;
// 数据最新版本号
@synthesize latestVersion;
// 数据下载地址
@synthesize downloadUrl;
// 数据包解密密钥
@synthesize decryptKey;

// 版本说明信息
//@synthesize updateType;
// 版本说明信息
@synthesize updateInfo;
// 数据发布时间
@synthesize releaseTime;
//是否有权限
@synthesize is_permissioned;
//是否需要更新data
@synthesize need_update_data;
//MD5
//@synthesize zip_md5;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"data_id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"need_update_app"]) {
            return @"needUpdateApp";
        }
        else if ([keyName isEqual:@"data_version_cur"]) {
            return @"curVersion";
        }
        else if ([keyName isEqual:@"data_version_latest"]) {
            return @"latestVersion";
        }
        else if ([keyName isEqual:@"download_url"]) {
            return @"downloadUrl";
        }
        else if ([keyName isEqual:@"data_encrypt_key"]) {
            return @"decryptKey";
        }
        else if ([keyName isEqual:@"update_type"]) {
            return @"updateType";
        }
        else if ([keyName isEqual:@"update_info"]) {
            return @"updateInfo";
        }
        else if ([keyName isEqual:@"data_release_time"]) {
            return @"releaseTime";
        }
//        else if ([keyName isEqual:@"zip_md5"]) {
//            return @"releaseTime";
//        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataId"]) {
                                                  return @"data_id";
                                              }
                                              else if ([keyName isEqual:@"needUpdateApp"]) {
                                                  return @"need_update_app";
                                              }
                                              else if ([keyName isEqual:@"curVersion"]) {
                                                  return @"data_version_cur";
                                              }
                                              else if ([keyName isEqual:@"latestVersion"]) {
                                                  return @"data_version_latest";
                                              }
                                              else if ([keyName isEqual:@"downloadUrl"]) {
                                                  return @"download_url";
                                              }
                                              else if ([keyName isEqual:@"decryptKey"]) {
                                                  return @"data_encrypt_key";
                                              }
                                              else if ([keyName isEqual:@"updateType"]) {
                                                  return @"update_type";
                                              }
                                              else if ([keyName isEqual:@"updateInfo"]) {
                                                  return @"update_info";
                                              }
                                              else if ([keyName isEqual:@"releaseTime"]) {
                                                  return @"data_release_time";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}


@end

/**
 * 关于data更新的服务器响应
 */
@implementation ServerResponseUpdateInfo

@synthesize status;
@synthesize message;
@synthesize details;
@synthesize msg_log;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"msg"]) {
            return @"message";
        }
        else if ([keyName isEqual:@"update_info"]) {
            return @"details";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"message"]) {
                                                  return @"msg";
                                              }
                                              else if ([keyName isEqual:@"details"]) {
                                                  return @"update_info";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}


@end


/**
 *关于服务器响应中data对应的json字符串解析
 */








/**
 *关于服务器响应中data中updateInfo对应的array的解析
 */
@implementation ServerResponseData
@synthesize needUpdateApp;
@synthesize needUpdateData;
@synthesize isPermissioned;
@synthesize dataId;
@synthesize currentDataVersion;
@synthesize latestDataVersion;
@synthesize downloadUrl;
@synthesize dataEncryptKey;
@synthesize updateInfo;
@synthesize dataReleaseTime;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"need_update_app"]) {
            return @"needUpdateApp";
        }
        else if ([keyName isEqual:@"need_update_data"]) {
            return @"needUpdateData";
        }
        else if ([keyName isEqual:@"is_permissioned"]) {
            return @"isPermissioned";
        }
        else if ([keyName isEqual:@"data_id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"data_version_cur"]) {
            return @"currentDataVersion";
        }
        else if ([keyName isEqual:@"data_version_latest"]) {
            return @"latestDataVersion";
        }
        else if ([keyName isEqual:@"download_url"]) {
            return @"downloadUrl";
        }
        else if ([keyName isEqual:@"data_encrypt_key"]) {
            return @"dataEncryptKey";
        }
        else if ([keyName isEqual:@"update_info"]) {
            return @"updateInfo";
        }
        else if ([keyName isEqual:@"data_release_time"]) {
            return @"dataReleaseTime";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"needUpdateApp"]) {
                                                  return @"need_update_app";
                                              }
                                              else if ([keyName isEqual:@"needUpdateData"]) {
                                                  return @"need_update_data";
                                              }
                                              else if ([keyName isEqual:@"isPermissioned"]) {
                                                  return @"is_permissioned";
                                              }
                                              else if ([keyName isEqual:@"dataId"]) {
                                                  return @"data_id";
                                              }
                                              else if ([keyName isEqual:@"currentDataVersion"]) {
                                                  return @"data_version_cur";
                                              }
                                              else if ([keyName isEqual:@"latestDataVersion"]) {
                                                  return @"data_version_latest";
                                              }
                                              else if ([keyName isEqual:@"downloadUrl"]) {
                                                  return @"download_url";
                                              }
                                              else if ([keyName isEqual:@"dataEncryptKey"]) {
                                                  return @"data_encrypt_key";
                                              }
                                              else if ([keyName isEqual:@"updateInfo"]) {
                                                  return @"update_info";
                                              }
                                              else if ([keyName isEqual:@"dataReleaseTime"]) {
                                                  return @"data_release_time";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}


@end



/**
 * 关于data的服务器响应
 */
@implementation ServerResponseOfKnowledgeData

#pragma properties
@synthesize encryptMethod;
@synthesize encryptKeyType;
@synthesize gUserId;
@synthesize data;
@synthesize appPlatform;
@synthesize appVersion;
@synthesize sessionId;



+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"encrypt_method"]) {
            return @"encryptMethod";
        }
        else if ([keyName isEqual:@"encrypt_key_type"]) {
            return @"encryptKeyType";
        }
        else if ([keyName isEqual:@"g_user_id"]) {
            return @"gUserId";
        }
        else if ([keyName isEqual:@"app_platform"]) {
            return @"appPlatform";
        }
        else if ([keyName isEqual:@"app_version"]) {
            return @"appVersion";
        }
        else if ([keyName isEqual:@"session_id"]) {
            return @"sessionId";
        }
        else {//data字段不需要解析吗？
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"encryptMethod"]) {
                                                  return @"encrypt_method";
                                              }
                                              else if ([keyName isEqual:@"encryptKeyType"]) {
                                                  return @"encrypt_key_type";
                                              }
                                              else if ([keyName isEqual:@"gUserId"]) {
                                                  return @"g_user_id";
                                              }
                                              else if ([keyName isEqual:@"appPlatform"]) {
                                                  return @"app_platform";
                                              }
                                              else if ([keyName isEqual:@"appVersion"]) {
                                                  return @"app_version";
                                              }
                                              else if ([keyName isEqual:@"sessionId"]) {
                                                  return @"session_id";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end



/**
 * 来自服务端的数据版本信息
 */
@implementation ServerDataVersionInfo

@synthesize dataId;

@synthesize dataCurVersion;
@synthesize dataLatestVersion;
@synthesize appVersionMin;
@synthesize appVersionMax;
@synthesize updateInfo;


+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"data_id"]) {
            return @"dataId";
        }
        //2.0中版本文件中不返回这个字段，所以注掉
//        else if ([keyName isEqual:@"data_name_en"]) {
//            return @"dataNameEn";
//        }
        else if ([keyName isEqual:@"cur_version"]) {//版本信息文件中没有这个字段不会报错吗？
            return @"dataCurVersion";
        }
        else if ([keyName isEqual:@"data_version"]) {
            return @"dataLatestVersion";
        }
        else if ([keyName isEqual:@"app_version_low"]) {
            return @"appVersionMin";
        }
        else if ([keyName isEqual:@"app_version_high"]) {
            return @"appVersionMax";
        }
        else if ([keyName isEqual:@"update_info"]) {
            return @"updateInfo";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataId"]) {
                                                  return @"data_id";
                                              }
//                                              else if ([keyName isEqual:@"dataNameEn"]) {
//                                                  return @"data_name_en";
//                                              }
                                              else if ([keyName isEqual:@"dataCurVersion"]) {
                                                  return @"cur_version";
                                              }
                                              else if ([keyName isEqual:@"dataLatestVersion"]) {
                                                  return @"data_version";
                                              }
                                              else if ([keyName isEqual:@"appVersionMin"]) {
                                                  return @"app_version_low";
                                              }
                                              else if ([keyName isEqual:@"appVersionMax"]) {
                                                  return @"app_version_high";
                                              }
                                              else if ([keyName isEqual:@"updateInfo"]) {
                                                  return @"update_info";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}


@end

