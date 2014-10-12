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

#pragma mark - getter
// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType;

#pragma mark - setter
- (BOOL)setData:(NSString *)dataId toStatus:(DataStatus)status;

@end
