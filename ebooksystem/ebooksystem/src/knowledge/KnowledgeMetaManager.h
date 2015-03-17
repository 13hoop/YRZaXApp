//
//  KnowledgeMetaManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/7/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KnowledgeDataTypes.h"

#import "KnowledgeMeta.h"



@interface KnowledgeMetaManager : NSObject

#pragma mark - singleton
+ (KnowledgeMetaManager *)instance;

#pragma mark - load & save
// load knowledge meta
- (NSArray *)loadKnowledgeMeta:(NSString *)fullFilePath;

// save knowledge meta
- (BOOL)saveKnowledgeMeta:(KnowledgeMeta *)knowledgeMeta;

// delete knowledge meta
- (BOOL)deleteKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType;
- (BOOL)deleteKnowledgeMetaWithDataId:(NSString *)dataId;


// clear knowledge metas
- (BOOL)clearKnowledgeMetas;

#pragma mark - getter
//get  all knowledge metas by dataType
- (NSArray *)getKnowledgeMetaWithDataType:(DataType)dataType;
//2.0 get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId;
// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType;

// get knowledge data version
- (NSString *)getKnowledgeDataVersionWithDataId:(NSString *)dataId andDataType:(DataType)dataType;

//2.0 get knowledge data version by dataId
- (NSString *)getKnowledgeDataVersionWithDataId:(NSString *)dataId;

// get searchable knowledge metas
- (NSArray *)getSearchableKnowledgeMetas;

//H:get knowledge metas with dataId and dataStatus
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataStatus:(DataStatus)dataStatus;

//H2.0:get knowledgeMeta by book_Categorey
- (NSArray *)getKnowledgeMetaWithBookCategory:(NSString *)bookCategory;


#pragma mark - setter
// 更新数据的状态及描述
- (BOOL)setDataStatusTo:(DataStatus)status andDataStatusDescTo:(NSString *)desc forDataWithDataId:(NSString *)dataId andType:(DataType)dataType;

#pragma mark - setter for 2.0

 //H2.0:更改数据库中的数据的版本号的操作：1、在get_downloadUrl时将获取的响应中的数据版本号存到latest字段 2、解包完成后将latest字段的值赋值给curversion，来实现更新数据版本号。
- (BOOL)setDataStatusTo:(DataStatus)status andDataStatusDescTo:(NSString *)desc andDataLatestVersion:(NSString *)latestVersion andDataPath:(NSString *)dataPath andDataStorageType:(DataStorageType)dataStorageType forDataWithDataId:(NSString *)dataId andType:(DataType)dataType;

//check dataStatus and downloadProgress and modify dataStatus
- (BOOL)setDataStatusforDataWithDataType:(DataType)dataType;

@end
