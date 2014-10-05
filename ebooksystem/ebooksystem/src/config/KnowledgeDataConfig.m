//
//  KnowledgeDataConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataConfig.h"

@implementation KnowledgeDataConfig

@synthesize knowledgeDataInitMode = _knowledgeDataInitMode;
@synthesize knowledgeUpdateCheckIntervalInMs = _knowledgeUpdateCheckIntervalInMs;

#pragma mark - singleton
+ (KnowledgeDataConfig *)instance {
    static KnowledgeDataConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - knowledge data
- (KnowledgeDataInitMode)knowledgeDataInitMode {
    return KNOWLEDGE_DATA_INIT_MODE_NONE;
}

- (int)knowledgeUpdateCheckIntervalInMs {
    return 60 * 60 * 1000;
}

@end
