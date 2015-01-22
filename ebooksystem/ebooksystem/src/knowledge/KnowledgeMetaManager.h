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

// clear knowledge metas
- (BOOL)clearKnowledgeMetas;

#pragma mark - getter
// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId;
// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType;

// get knowledge data version
- (NSString *)getKnowledgeDataVersionWithDataId:(NSString *)dataId andDataType:(DataType)dataType;

// get searchable knowledge metas
- (NSArray *)getSearchableKnowledgeMetas;

//H:get knowledge metas with dataId and dataStatus
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataStatus:(DataStatus)dataStatus;



#pragma mark - setter
// 更新数据的状态及描述
- (BOOL)setDataStatusTo:(DataStatus)status andDataStatusDescTo:(NSString *)desc forDataWithDataId:(NSString *)dataId andType:(DataType)dataType;

//H:更新数据在app中的相对路径，数据状态，以及更新版本号的操作
- (BOOL)setDataStatusTo:(DataStatus)status andDataPath:(NSString *)dataPath andDataCurVersion:(NSString *)curVersion andDataStorageType:(DataStorageType)dataStorageType forDataWithDataId:(NSString *)dataId andType:(DataType)dataType;

@end
