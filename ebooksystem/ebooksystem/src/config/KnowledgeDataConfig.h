//
//  KnowledgeDataConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDataTypes.h"

@interface KnowledgeDataConfig : NSObject

#pragma mark - properties

#pragma mark - url related properties
// 向服务器请求数据的url, 用于数据下载
@property (nonatomic, copy, readonly) NSString *dataUrlForDownload;
// 向服务器请求数据版本信息的文件的url, 用于数据更新前获取数据的最新版本
@property (nonatomic, copy, readonly) NSString *dataUrlForVersion;
// 向服务器请求数据更新的url, 用于数据更新
@property (nonatomic, copy, readonly) NSString *dataUrlForUpdate;


#pragma mark - data related properties
// knowledge data init mode
@property (nonatomic, copy) NSString *keyForKnowledgeDataInitedFlag;

// knowledge data root path in assets
@property (nonatomic, copy) NSString *knowledgeDataRootPathInAssets;

// knowledge data root path in sandbox
@property (nonatomic, copy) NSString *knowledgeDataRootPathInDocuments;

// knowledge data root path in sandbox
// app中的数据根目录, (1) 若app自带全量数据, 则为asset/knowledge_data目录; (2) 若app未自带全量数据, 则为Documents/knowledge_data目录.
@property (nonatomic, copy) NSString *knowledgeDataRootPathInApp;

// knowledge data download root path in sandbox
@property (nonatomic, copy, readonly) NSString *knowledgeDataDownloadRootPathInDocuments;

// knowledge data filename
@property (nonatomic, copy, readonly) NSString *knowledgeDataFilename;
// knowledge meta filename
@property (nonatomic, copy, readonly) NSString *knowledgeMetaFilename;

// knowledge data init mode
@property (nonatomic, assign) KnowledgeDataInitMode knowledgeDataInitMode;

// knowledge data updater
@property (nonatomic, assign) int knowledgeUpdateCheckIntervalInMs;

// knowledge data update mode
@property (nonatomic, assign) DataUpdateMode knowledgeDataUpdateMode;

#pragma mark - methods
// singleton
+ (KnowledgeDataConfig *)instance;


@end
