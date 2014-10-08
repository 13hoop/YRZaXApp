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

// get data
- (NSString *)getData:(NSString *)dataId;

// search data
- (NSString *)searchData:(NSString *)searchId;

#pragma mark - test
// test
- (void)test;

@end
