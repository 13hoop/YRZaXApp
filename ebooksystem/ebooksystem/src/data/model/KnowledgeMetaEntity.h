//
//  KnowledgeMetaEntity.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/28.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KnowledgeMetaEntity : NSManagedObject

@property (nonatomic, retain) NSString * bookCategory;
@property (nonatomic, retain) NSString * bookMeta;
@property (nonatomic, retain) NSDate * checkTime;
@property (nonatomic, retain) NSString * childIds;
@property (nonatomic, retain) NSString * completeBookId;
@property (nonatomic, retain) NSString * coverSrc;
@property (nonatomic, retain) NSString * curVersion;
@property (nonatomic, retain) NSString * dataId;
@property (nonatomic, retain) NSString * dataNameCh;
@property (nonatomic, retain) NSString * dataNameEn;
@property (nonatomic, retain) NSString * dataPath;
@property (nonatomic, retain) NSNumber * dataPathType;
@property (nonatomic, retain) NSNumber * dataSearchType;
@property (nonatomic, retain) NSNumber * dataStatus;
@property (nonatomic, retain) NSString * dataStatusDesc;
@property (nonatomic, retain) NSNumber * dataStorageType;
@property (nonatomic, retain) NSNumber * dataType;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * isUpdateSeed;
@property (nonatomic, retain) NSString * latestVersion;
@property (nonatomic, retain) NSString * nodeContentDir;
@property (nonatomic, retain) NSString * parentId;
@property (nonatomic, retain) NSString * parentNameCh;
@property (nonatomic, retain) NSString * parentNameEn;
@property (nonatomic, retain) NSDate * releaseTime;
@property (nonatomic, retain) NSString * siblingIds;
@property (nonatomic, retain) NSString * updateInfo;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSNumber * updateType;
@property (nonatomic, retain) NSString * bookReadType;

@end
