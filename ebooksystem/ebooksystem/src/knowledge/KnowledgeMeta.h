//
//  KnowledgeMeta.h
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDataTypes.h"


@class KnowledgeMetaEntity;
@class KnowledgeSearchEntity;


@interface KnowledgeMeta : NSObject

#pragma mark - properties
// 在sqlite中的主键id
@property (nonatomic, assign) NSUInteger pkId;

@property (nonatomic, copy) NSString *dataId;
@property (nonatomic, copy) NSString *dataNameEn;
@property (nonatomic, copy) NSString *dataNameCh;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) DataType dataType;
@property (nonatomic, assign) DataStorageType dataStorageType;
@property (nonatomic, assign) DataPathType dataPathType;
@property (nonatomic, copy) NSString *dataPath;

@property (nonatomic, assign) DataStatus dataStatus;

@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *parentNameEn;
@property (nonatomic, copy) NSString *parentNameCh;

@property (nonatomic, copy) NSString *childIds;
@property (nonatomic, copy) NSString *siblingIds;

@property (nonatomic, copy) NSString *nodeContentDir;

@property (nonatomic, assign) BOOL isUpdateSeed;

@property (nonatomic, copy) NSDate *updateTime;
@property (nonatomic, assign) DataUpdateType updateType;
@property (nonatomic, copy) NSString *updateInfo;

@property (nonatomic, copy) NSDate *checkTime;
@property (nonatomic, copy) NSString *curVersion;
@property (nonatomic, copy) NSString *latestVersion;
@property (nonatomic, copy) NSDate *releaseTime;

// 检索倒排表
@property (nonatomic, copy) NSArray *searchReverseInfo;


#pragma mark - 与KnowledgeMetaEntity转换
// 由KnowledgeMetaEntity转为KnowledgeMeta
+ (KnowledgeMeta *)fromKnowledgeMetaEntity:(KnowledgeMetaEntity *)knowledgeMetaEntity;

// 由KnowledgeMeta转为KnowledgeMetaEntity
- (KnowledgeMetaEntity *)toKnowledgeMetaEntity;

// 由KnowledgeMeta转为KnowledgeSearchEntity
- (NSArray *)toKnowledgeSearchEntity;

@end
