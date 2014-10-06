//
//  KnowledgeMeta.m
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeMeta.h"
#import "KnowledgeSearchReverseInfo.h"
#import "KnowledgeMetaEntity.h"
#import "KnowledgeSearchEntity.h"


@implementation KnowledgeMeta

// 在sqlite中的主键id
@synthesize pkId;

@synthesize dataId;
@synthesize dataNameEn;
@synthesize dataNameCh;
@synthesize desc;

@synthesize dataType;
@synthesize dataStorageType;
@synthesize dataPathType;
@synthesize dataPath;

@synthesize dataStatus;

@synthesize parentId;
@synthesize parentNameEn;
@synthesize parentNameCh;

@synthesize childIds;
@synthesize siblingIds;

@synthesize nodeContentDir;

@synthesize isUpdateSeed;

@synthesize updateTime;
@synthesize updateType;
@synthesize updateInfo;

@synthesize checkTime;
@synthesize curVersion;
@synthesize latestVersion;
@synthesize releaseTime;

@synthesize searchReverseInfo;


#pragma mark - 与KnowledgeMetaEntity转换
// 由KnowledgeMetaEntity转为KnowledgeMeta
+ (KnowledgeMeta *)fromKnowledgeMetaEntity:(KnowledgeMetaEntity *)knowledgeMetaEntity {
    if (knowledgeMetaEntity == nil) {
        return nil;
    }
    
    KnowledgeMeta *knowledgeMeta = [[KnowledgeMeta alloc] init];
    
    knowledgeMeta.pkId = [knowledgeMetaEntity.pkId unsignedIntegerValue];
    knowledgeMeta.dataId = knowledgeMetaEntity.dataId;
    knowledgeMeta.dataNameEn = knowledgeMetaEntity.dataNameEn;
    knowledgeMeta.dataNameCh = knowledgeMetaEntity.dataNameCh;
    knowledgeMeta.desc = knowledgeMetaEntity.desc;
    
    knowledgeMeta.dataType = (DataType)[knowledgeMetaEntity.dataType integerValue];
    knowledgeMeta.dataStorageType = (DataStorageType)[knowledgeMetaEntity.dataStorageType integerValue];
    knowledgeMeta.dataPathType = (DataPathType)[knowledgeMetaEntity.dataPathType integerValue];
    knowledgeMeta.dataPath = knowledgeMetaEntity.dataPath;
    
    knowledgeMeta.dataStatus = (DataStatus)[knowledgeMetaEntity.dataStatus integerValue];
    
    knowledgeMeta.parentId = knowledgeMetaEntity.parentId;
    knowledgeMeta.parentNameEn = knowledgeMetaEntity.parentNameEn;
    knowledgeMeta.parentNameCh = knowledgeMetaEntity.parentNameCh;
    
    knowledgeMeta.childIds = knowledgeMetaEntity.childIds;
    knowledgeMeta.siblingIds = knowledgeMetaEntity.siblingIds;
    
    knowledgeMeta.nodeContentDir = knowledgeMetaEntity.nodeContentDir;
    
    knowledgeMeta.isUpdateSeed = knowledgeMetaEntity.isUpdateSeed;
    
    knowledgeMeta.updateTime = knowledgeMetaEntity.updateTime;
    knowledgeMeta.updateType = (DataUpdateType)[knowledgeMetaEntity.updateType integerValue];
    knowledgeMeta.updateInfo = knowledgeMetaEntity.updateInfo;
    
    knowledgeMeta.checkTime = knowledgeMetaEntity.checkTime;
    knowledgeMeta.curVersion = knowledgeMetaEntity.curVersion;
    knowledgeMeta.latestVersion = knowledgeMetaEntity.latestVersion;
    knowledgeMeta.releaseTime = knowledgeMetaEntity.releaseTime;
    
    return knowledgeMeta;
}

// 由KnowledgeMeta转为KnowledgeMetaEntity
- (KnowledgeMetaEntity *)toKnowledgeMetaEntity {
    KnowledgeMetaEntity *knowledgeMetaEntity = [[KnowledgeMetaEntity alloc] init];
    
    knowledgeMetaEntity.pkId = [NSNumber numberWithUnsignedInteger:self.pkId];
    knowledgeMetaEntity.dataId = self.dataId;
    knowledgeMetaEntity.dataNameEn = self.dataNameEn;
    knowledgeMetaEntity.dataNameCh = self.dataNameCh;
    knowledgeMetaEntity.desc = self.desc;
    
    knowledgeMetaEntity.dataType = [NSNumber numberWithInteger:self.dataType];
    knowledgeMetaEntity.dataStorageType = [NSNumber numberWithInteger:self.dataStorageType];
    knowledgeMetaEntity.dataPathType = [NSNumber numberWithInteger:self.dataPathType];
    knowledgeMetaEntity.dataPath = self.dataPath;
    
    knowledgeMetaEntity.dataStatus = [NSNumber numberWithInteger:self.dataStatus];
    
    knowledgeMetaEntity.parentId = self.parentId;
    knowledgeMetaEntity.parentNameEn = self.parentNameEn;
    knowledgeMetaEntity.parentNameCh = self.parentNameCh;
    
    knowledgeMetaEntity.childIds = self.childIds;
    knowledgeMetaEntity.siblingIds = self.siblingIds;
    
    knowledgeMetaEntity.nodeContentDir = self.nodeContentDir;
    
    knowledgeMetaEntity.isUpdateSeed = [NSNumber numberWithBool:self.isUpdateSeed];
    
    knowledgeMetaEntity.updateTime = self.updateTime;
    knowledgeMetaEntity.updateType = [NSNumber numberWithInteger:self.updateType];
    knowledgeMetaEntity.updateInfo = self.updateInfo;
    
    knowledgeMetaEntity.checkTime = self.checkTime;
    knowledgeMetaEntity.curVersion = self.curVersion;
    knowledgeMetaEntity.latestVersion = self.latestVersion;
    knowledgeMetaEntity.releaseTime = self.releaseTime;

    return knowledgeMetaEntity;
}

// 由KnowledgeMeta转为KnowledgeSearchEntity
- (NSArray *)toKnowledgeSearchEntity {
    if (searchReverseInfo == nil || searchReverseInfo.count <= 0) {
        return nil;
    }
    
    NSMutableArray *searchEnties = [[NSMutableArray alloc] init];
    
    for (id obj in self.searchReverseInfo) {
        KnowledgeSearchReverseInfo *knowledgeSearchReverseInfo = (KnowledgeSearchReverseInfo *)obj;
        if (knowledgeSearchReverseInfo == nil || knowledgeSearchReverseInfo.searchResults == nil || knowledgeSearchReverseInfo.searchResults.count <= 0) {
            continue;
        }
        
        for (id result in knowledgeSearchReverseInfo.searchResults) {
            KnowledgeSearchResultItem *knowledgeSearchResultItem = (KnowledgeSearchResultItem *)result;
            if (knowledgeSearchResultItem == nil) {
                continue;
            }
            
            KnowledgeSearchEntity *knowledgeSearchEntity = [[KnowledgeSearchEntity alloc] init];
            
            knowledgeSearchEntity.searchId = knowledgeSearchReverseInfo.searchId;
            knowledgeSearchEntity.dataId = knowledgeSearchResultItem.dataId;
            knowledgeSearchEntity.dataNameEn = knowledgeSearchResultItem.dataNameEn;
            knowledgeSearchEntity.dataNameCh = knowledgeSearchResultItem.dataNameCh;
            
            [searchEnties addObject:knowledgeSearchEntity];
        }
    }
    
    return searchEnties;
}

@end
