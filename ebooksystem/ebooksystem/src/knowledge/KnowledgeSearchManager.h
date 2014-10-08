//
//  KnowledgeSearchManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KnowledgeSearchManager : NSObject

#pragma mark - singleton
+ (KnowledgeSearchManager *)instance;

#pragma mark - search
// search data
- (NSArray *)searchData:(NSString *)searchId;

@end
