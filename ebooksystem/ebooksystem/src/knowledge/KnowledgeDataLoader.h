//
//  KnowledgeDataLoader.h
//  ebooksystem
//
//  Created by zhenghao on 10/21/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KnowledgeDataLoader : NSObject

#pragma mark - singleton
+ (KnowledgeDataLoader *)instance;

#pragma mark - load knowledge
// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSString *)getKnowledgeDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename;

#pragma mark - test
- (BOOL)test;

@end
