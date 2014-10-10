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
@property (nonatomic, copy) id<KnowledgeDataStatusDelegate> dataStatusDelegate;


#pragma mark - singleton
+ (KnowledgeDataManager *)instance;

#pragma mark - copy data files
// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData;

#pragma mark - load data content
// load knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeMetaEntity *)knowledgeMetaEntity;

#pragma mark - download knowledge data
// start downloading
- (BOOL)startDownloadData:(NSString *)dataId;



@end
