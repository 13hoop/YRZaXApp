//
//  KnowledgeManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeManager.h"
#import "Config.h"



// KnowledgeManager
@interface KnowledgeManager() {
    
}

// init
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode;
- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs;

@end


@implementation KnowledgeManager

#pragma mark - singleton

+ (KnowledgeManager *)instance {
    static KnowledgeManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initKnowledgeData:[Config instance].knowledgeDataConfig.knowledgeDataInitMode];
        [sharedInstance initKnowledgeUpdater:[Config instance].knowledgeDataConfig.knowledgeUpdateCheckIntervalInMs];
    });
    
    return sharedInstance;
}

#pragma mark - init
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode {
    switch(mode) {
        case KNOWLEDGE_DATA_INIT_MODE_NONE:
            break;
        case KNOWLEDGE_DATA_INIT_MODE_ASYNC:
            break;
        case KNOWLEDGE_DATA_INIT_MODE_SYNC:
            break;
        default:
            break;
    }
    
    return TRUE;
}

- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs {
    return TRUE;
}

@end
