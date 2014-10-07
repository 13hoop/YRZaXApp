//
//  KnowledgeDataConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDataTypes.h"

@interface KnowledgeDataConfig : NSObject

#pragma mark - properties
// knowledge data init mode
@property(nonatomic, copy) NSString *keyForKnowledgeDataInitedFlag;

// knowledge data root path in assets
@property(nonatomic, copy) NSString *knowledgeDataRootPathInAssets;

// knowledge data root path in sandbox
@property(nonatomic, copy) NSString *knowledgeDataRootPathInDocuments;

// knowledge data init mode
@property(nonatomic, assign) KnowledgeDataInitMode knowledgeDataInitMode;

// knowledge data updater
@property(nonatomic, assign) int knowledgeUpdateCheckIntervalInMs;


#pragma mark - methods
// singleton
+ (KnowledgeDataConfig *)instance;


@end
