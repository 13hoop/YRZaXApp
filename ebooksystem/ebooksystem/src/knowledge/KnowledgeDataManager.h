//
//  KnowledgeDataManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>


@class KnowledgeMetaEntity;


@interface KnowledgeDataManager : NSObject

#pragma mark - singleton
+ (KnowledgeDataManager *)instance;

#pragma mark - knowledge data operations
// load knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeMetaEntity *)knowledgeMetaEntity;

@end
