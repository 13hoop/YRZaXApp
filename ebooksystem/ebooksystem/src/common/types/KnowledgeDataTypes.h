//
//  KnowledgeDataTypes.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#ifndef ebooksystem_KnowledgeDataTypes_h
#define ebooksystem_KnowledgeDataTypes_h

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
    DATA_TYPE_UNKNOWN, DATA_TYPE_META, // meta数据
    DATA_TYPE_DATA_SOURCE, // data数据, 用作app的数据源
    DATA_TYPE_RENDER, // render数据, 用来对数据源进行渲染. e.g, html, css, js, etc.
    DATA_TYPE_DATA_UGC // 用户产生的数据, 如学习记录等
} DataType;

/**
 * App中的数据存储路径的类型
 *
 */
typedef enum {
    DATA_STORAGE_TYPE_UNKNOWN, DATA_STORAGE_APP_ASSETS, // 数据存储于app的assets中
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
//    @SerializedName("0")
    DATA_PATH_TYPE_FILE, // meta.json中记录的path为文件系统中的路径
} DataPathType;

/**
 * 数据的状态
 *
 */
typedef enum {
    DATA_STATUS_UNKNOWN, // 未知
    DATA_STATUS_AVAIL, // 可用
    DATA_STATUS_UPDATING, // 更新中
    DATA_STATUS_UPDATED // 已更新
} DataStatus;

/**
 * 数据更新的类型
 *
 */
typedef enum {
//    @SerializedName("0")
    DATA_UPDATE_TYPE_NODE, // 节点更新
//    @SerializedName("1")
    DATA_UPDATE_TYPE_NODE_AND_CHILDREN // 节点及其所有子节点均需更新
} DataUpdateType;

/**
 * 数据更新时的操作类型. e.g, 增加/替换, 删除
 *
 */
typedef enum {
    DATA_OPERATION_TYPE_ADD_OR_REPLACE, // 增加/替换
    DATA_OPERATION_TYPE_DELETE // 删除
} DataOperationType;

#endif
