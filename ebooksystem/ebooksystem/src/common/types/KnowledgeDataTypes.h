//
//  KnowledgeDataTypes.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#ifndef ebooksystem_KnowledgeDataTypes_h
#define ebooksystem_KnowledgeDataTypes_h

#import "JSONModel.h"


#pragma mark - enums
// types
// 数据初始化模式
typedef enum {
    KNOWLEDGE_DATA_INIT_MODE_NONE = 0, // 不做初始化
    KNOWLEDGE_DATA_INIT_MODE_ASYNC, // 异步初始化
    KNOWLEDGE_DATA_INIT_MODE_SYNC // 同步初始化
} KnowledgeDataInitMode;

/**
 * App中涉及的数据类型
 */
typedef enum {
    DATA_TYPE_UNKNOWN = -1,
    DATA_TYPE_META, // meta数据
    DATA_TYPE_DATA_SOURCE, // data数据, 用作app的数据源
    DATA_TYPE_RENDER, // render数据, 用来对数据源进行渲染. e.g, html, css, js, etc.
    DATA_TYPE_DATA_UGC // 用户产生的数据, 如学习记录等
} DataType;

/**
 * App中的数据存储路径的类型. 来自app.
 *
 */
typedef enum {
    DATA_STORAGE_TYPE_UNKNOWN = -1,
    DATA_STORAGE_APP_ASSETS, // 数据存储于app的assets中
    DATA_STORAGE_APP_RAW, // 数据存储于app的raw中
    DATA_STORAGE_SHARED_PREFERENCE, // 数据存储于sharedPreferences中
    DATA_STORAGE_SQLITE, // 数据存储于sqlite中
    DATA_STORAGE_INTERNAL_STORAGE, // 数据存储于手机的内部存储空间中
    DATA_STORAGE_EXTERNAL_STORAGE // 数据存储于手机的外部存储空间(sd卡)中
} DataStorageType;

/**
 * App中的数据路径的类型. e.g, file, url, etc. 来自server.
 *
 * @author zhenghao
 *
 */
typedef enum {
    DATA_PATH_TYPE_FILE = 0, // meta.json中记录的path为文件系统中的路径
} DataPathType;

/**
 * App中的数据在检索时的处理方式. 0: 不检索, 1: 检索. 来自server.
 *
 * @author zhenghao
 *
 */
typedef enum {
    DATA_SEARCH_IGNORE = 0,
    DATA_SEARCH_SEARCHABLE
} DataSearchType;

/**
 * 数据的状态
 *
 */
typedef enum {
    DATA_STATUS_UNKNOWN = -1, // 未知
    DATA_STATUS_AVAIL, // 可用
    
    DATA_STATUS_DOWNLOAD_PREPARING, // 准备下载
    DATA_STATUS_DOWNLOAD_IN_PROGRESS, // 下载中
    DATA_STATUS_DOWNLOAD_COMPLETED, // 下载完成
    
    DATA_STATUS_UNPACK_PREPARING, // 准备解包
    DATA_STATUS_UNPACK_IN_PROGRESS, // 解包中
    DATA_STATUS_UNPACK_COMPLETED, // 解包完成
    
    DATA_STATUS_UPDATE_DETECTED, // 有可用更新
    DATA_STATUS_UPDATE_PREPARING, // 准备更新
    DATA_STATUS_UPDATE_IN_PROGRESS, // 更新中
    DATA_STATUS_UPDATE_COMPLETED, // 更新完成
} DataStatus;

/**
 * 数据更新的模式
 *
 */
typedef enum {
    DATA_UPDATE_MODE_CHECK = 0, // 检查更新, 并将coreData中的相关数据标为可更新
    DATA_UPDATE_MODE_CHECK_AND_UPDATE // 检查更新, 并完成更新
} DataUpdateMode;

/**
 * 数据更新的类型
 *
 */
typedef enum {
//    @SerializedName("0")
    DATA_UPDATE_TYPE_NODE = 0, // 节点更新
//    @SerializedName("1")
    DATA_UPDATE_TYPE_NODE_AND_CHILDREN // 节点及其所有子节点均需更新
} DataUpdateType;

/**
 * 数据更新时的操作类型. e.g, 增加/替换, 删除
 *
 */
typedef enum {
    DATA_OPERATION_TYPE_ADD_OR_REPLACE = 0, // 增加/替换
    DATA_OPERATION_TYPE_DELETE // 删除
} DataOperationType;


#pragma mark - AppRequest
/**
 * 数据下载请求
 */
@interface DataDownloadRequestInfo : JSONModel

@property (nonatomic, copy) NSString *dataId;

@end


/**
 * 本地数据信息
 */
@protocol DataInfo // JsonModel中的"Model collections"要求
@end

@interface DataInfo : JSONModel

@property (nonatomic, copy) NSString *dataId;
@property (nonatomic, copy) NSString *curVersion;

@end

/**
 * 数据更新请求
 */
@interface DataUpdateRequestInfo : JSONModel

// 本地数据信息集合
@property (nonatomic, copy) NSArray<DataInfo> *dataInfo;

@end



#pragma mark - ServerResponse
/**
 * 关于data信息的服务器响应
 */
@interface ServerResponseDataInfo : JSONModel

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString<Optional> *dataId;
// 数据最新版本号
@property (nonatomic, copy) NSString<Optional> *dataVersion;
// 数据下载地址
@property (nonatomic, copy) NSString<Optional> *downloadUrl;
// 数据包解密密钥
@property (nonatomic, copy) NSString<Optional> *decryptKey;
// 版本说明信息
@property (nonatomic, copy) NSString<Optional> *updateInfo;
// 数据发布时间
@property (nonatomic, copy) NSDate<Optional> *releaseTime;


@end

/**
 * 关于data更新详情的服务器响应
 */
@interface ServerResponseUpdateInfoDetail : JSONModel

// 是否需要更新app. 0: no, 1: yes
@property (nonatomic, copy) NSString *needUpdateApp;
// 数据id
@property (nonatomic, copy) NSString *dataId;
// 数据当前版本号
@property (nonatomic, copy) NSString *curVersion;
// 数据最新版本号
@property (nonatomic, copy) NSString *latestVersion;
// 数据下载地址
@property (nonatomic, copy) NSString *downloadUrl;
// 数据包解密密钥
@property (nonatomic, copy) NSString *decryptKey;

// 版本说明信息
@property (nonatomic, copy) NSString *updateType;
// 版本说明信息
@property (nonatomic, copy) NSString *updateInfo;
// 数据发布时间
@property (nonatomic, copy) NSDate *releaseTime;


@end

/**
 * 关于data更新的服务器响应
 */
@interface ServerResponseUpdateInfo : JSONModel

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSArray *details;

@end

/**
 * 关于data的服务器响应
 */
@interface ServerResponseOfKnowledgeData : JSONModel

#pragma properties
// encryptMethod
@property (nonatomic, assign) NSInteger encryptMethod;
// encryptKeyType
@property (nonatomic, assign) NSInteger encryptKeyType;
// username
@property (nonatomic, copy) NSString *username;
// app platform
@property (nonatomic, copy) NSString<Optional> *appPlatform;
// app version
@property (nonatomic, copy) NSString<Optional> *appVersion;
// deviceId
@property (nonatomic, copy) NSString<Optional> *deviceId;
// data string, which is encoded
@property (nonatomic, copy) NSString *data;

//@property (nonatomic, copy) ServerResponseDataInfo<Optional> *dataInfo;
@property (nonatomic, copy) ServerResponseUpdateInfo<Optional> *updateInfo;

@end


/**
 * 来自服务端的数据版本信息
 */
@interface ServerDataVersionInfo : JSONModel

// 数据id
@property (nonatomic, copy) NSString<Optional> *dataId;
// 数据英文名
@property (nonatomic, copy) NSString<Optional> *dataNameEn;
// 数据当前版本号. 此字段为app中为避免性能损失而自行添加, 非server提供
@property (nonatomic, copy) NSString<Optional> *dataCurVersion;
// 数据最新版本号
@property (nonatomic, copy) NSString<Optional> *dataLatestVersion;
// 适配此数据的app最低版本
@property (nonatomic, copy) NSString<Optional> *appVersionMin;
// 适配此数据的app最高版本
@property (nonatomic, copy) NSString<Optional> *appVersionMax;
// 此数据的app的更新信息
@property (nonatomic, copy) NSString<Optional> *updateInfo;


@end

#endif
