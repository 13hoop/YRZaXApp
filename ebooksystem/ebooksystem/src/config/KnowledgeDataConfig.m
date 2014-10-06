//
//  KnowledgeDataConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataConfig.h"
#import "PathUtil.h"

@interface KnowledgeDataConfig()

// knowledge data的根目录名
@property (nonatomic, copy) NSString *knowledgeDataRootDirName;

@end


@implementation KnowledgeDataConfig

@synthesize keyForKnowledgeDataInitedFlag = _keyForKnowledgeDataInitedFlag;
@synthesize knowledgeDataRootPathInAssets = _knowledgeDataRootPathInAssets;
@synthesize knowledgeDataRootPathInDocuments = _knowledgeDataRootPathInDocuments;
@synthesize knowledgeDataRootDirName = _knowledgeDataRootDirName;

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

// knowledge inited flag key, for storing in user defaults
- (NSString *)keyForKnowledgeDataInitedFlag {
    return @"knowledge_data_inited";
}

// knowledge data root path in assets
- (NSString *)knowledgeDataRootPathInAssets {
    if (_knowledgeDataRootPathInAssets == nil) {
        NSString *bundlePath = [PathUtil getBundlePath];
        _knowledgeDataRootPathInAssets = [NSString stringWithFormat:@"%@/%@/%@", bundlePath, @"assets", self.knowledgeDataRootDirName];
    }
    
    return _knowledgeDataRootPathInAssets;
}

// knowledge data root path in sandbox
- (NSString *)knowledgeDataRootPathInDocuments {
    if (_knowledgeDataRootPathInDocuments == nil) {
        NSString *documentsPath = [PathUtil getDocumentsPath];
        
        _knowledgeDataRootPathInDocuments = [NSString stringWithFormat:@"%@/%@", documentsPath, self.knowledgeDataRootDirName];
    }
    return _knowledgeDataRootPathInDocuments;
}

- (NSString *)knowledgeDataRootDirName {
    return @"knowledge_data";
}

- (KnowledgeDataInitMode)knowledgeDataInitMode {
    //    return KNOWLEDGE_DATA_INIT_MODE_NONE;
    return KNOWLEDGE_DATA_INIT_MODE_SYNC;
}

- (int)knowledgeUpdateCheckIntervalInMs {
    return 60 * 60 * 1000;
}

@end
