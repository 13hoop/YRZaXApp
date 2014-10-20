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
        if ([keyName isEqual:@"id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"version"]) {
            return @"curVersion";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"dataId"]) {
                                                  return @"id";
                                              }
                                              else if ([keyName isEqual:@"curVersion"]) {
                                                  return @"version";
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
@synthesize updateType;
// 版本说明信息
@synthesize updateInfo;
// 数据发布时间
@synthesize releaseTime;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"need_update_app"]) {
            return @"needUpdateApp";
        }
        else if ([keyName isEqual:@"cur_version"]) {
            return @"curVersion";
        }
        else if ([keyName isEqual:@"latest_version"]) {
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
                                              else if ([keyName isEqual:@"needUpdateApp"]) {
                                                  return @"need_update_app";
                                              }
                                              else if ([keyName isEqual:@"curVersion"]) {
                                                  return @"cur_version";
                                              }
                                              else if ([keyName isEqual:@"latestVersion"]) {
                                                  return @"latest_version";
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
                                                  return @"release_time";
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
 * 关于data的服务器响应
 */
@implementation ServerResponseOfKnowledgeData

#pragma properties
@synthesize encryptMethod;
@synthesize encryptKeyType;
@synthesize username;
@synthesize appPlatform;
@synthesize appVersion;
@synthesize deviceId;
@synthesize data;

//@synthesize dataInfo;
@synthesize updateInfo;

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"encrypt_method"]) {
            return @"encryptMethod";
        }
        else if ([keyName isEqual:@"encrypt_key_type"]) {
            return @"encryptKeyType";
        }
        else if ([keyName isEqual:@"user_name"]) {
            return @"username";
        }
        else if ([keyName isEqual:@"app_platform"]) {
            return @"appPlatform";
        }
        else if ([keyName isEqual:@"app_version"]) {
            return @"appVersion";
        }
        else if ([keyName isEqual:@"device_id"]) {
            return @"deviceId";
        }
        else {
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
                                              else if ([keyName isEqual:@"username"]) {
                                                  return @"user_name";
                                              }
                                              else if ([keyName isEqual:@"appPlatform"]) {
                                                  return @"app_platform";
                                              }
                                              else if ([keyName isEqual:@"appVersion"]) {
                                                  return @"app_version";
                                              }
                                              else if ([keyName isEqual:@"deviceId"]) {
                                                  return @"device_id";
                                              }                                              else {
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
@synthesize dataNameEn;
@synthesize dataCurVersion;
@synthesize dataLatestVersion;
@synthesize appVersionMin;
@synthesize appVersionMax;
@synthesize updateInfo;


+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"id"]) {
            return @"dataId";
        }
        else if ([keyName isEqual:@"data_name_en"]) {
            return @"dataNameEn";
        }
        else if ([keyName isEqual:@"cur_version"]) {
            return @"dataCurVersion";
        }
        else if ([keyName isEqual:@"version"]) {
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
                                                  return @"id";
                                              }
                                              else if ([keyName isEqual:@"dataNameEn"]) {
                                                  return @"data_name_en";
                                              }
                                              else if ([keyName isEqual:@"dataCurVersion"]) {
                                                  return @"cur_version";
                                              }
                                              else if ([keyName isEqual:@"dataLatestVersion"]) {
                                                  return @"version";
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

