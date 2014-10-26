//
//  KnowledgeDataManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>


@class KnowledgeMetaEntity;


@protocol KnowledgeDataStatusDelegate <NSObject>

@optional
- (BOOL)knowledgeData:(NSString *)dataId downloadedToPath:(NSString *)dataPath successfully:(BOOL)succ;
- (BOOL)knowledgeDataAtPath:(NSString *)dataPath updatedSuccessfully:(BOOL)succ;

@end


@interface KnowledgeDataManager : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *lastError;

#pragma mark - delegate
@property (nonatomic, retain) id<KnowledgeDataStatusDelegate> dataStatusDelegate;


#pragma mark - singleton
+ (KnowledgeDataManager *)instance;

#pragma mark - copy data files
// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData;

#pragma mark - load data content
// load knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeMetaEntity *)knowledgeMetaEntity;

// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSString *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename;

#pragma mark - download knowledge data
// start downloading
- (BOOL)startDownloadData:(NSString *)dataId;

#pragma mark - data update
// check data update, and apply update according to update mode
- (BOOL)startUpdateData;
// check data update, and auto apply update
- (BOOL)startUpdateData:(NSString *)dataId;

#pragma mark - search
// search data
- (NSArray *)searchData:(NSString *)searchId;

@end
