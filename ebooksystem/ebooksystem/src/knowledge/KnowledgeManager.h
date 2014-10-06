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

// test
- (void)test;

@end
