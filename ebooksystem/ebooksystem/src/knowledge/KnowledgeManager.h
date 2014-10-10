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
// remote data fetch
- (BOOL)getRemoteData:(NSString *)dataId;

// local data search
- (NSString *)searchLocalData:(NSString *)searchId;

#pragma mark - test
// test
- (void)test;

@end
