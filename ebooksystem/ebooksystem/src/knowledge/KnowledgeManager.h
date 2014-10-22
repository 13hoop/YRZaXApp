//
//  KnowledgeManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KnowledgeManager : NSObject

#pragma mark - singleton
// singleton
+ (KnowledgeManager *)instance;

#pragma mark - methods for js call
// get page path
- (NSString *)getPagePath:(NSString *)dataId;

// local data fetch
- (NSString *)getLocalData:(NSString *)dataId;
// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSString *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename;
// remote data fetch
- (BOOL)getRemoteData:(NSString *)dataId;

// check data update
- (BOOL)startCheckDataUpdate;

// local data search
- (NSString *)searchLocalData:(NSString *)searchId;

// get data status
- (NSString *)getDataStatus:(NSString *)dataId;

#pragma mark - test
// test
- (void)test;

@end
