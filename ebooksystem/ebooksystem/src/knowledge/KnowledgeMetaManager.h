//
//  KnowledgeMetaManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/7/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KnowledgeMeta;



@interface KnowledgeMetaManager : NSObject

#pragma mark - singleton
+ (KnowledgeMetaManager *)instance;

// load knowledge meta
- (NSArray *)loadKnowledgeMeta:(NSString *)fullFilePath;

// save knowledge meta
- (BOOL)saveKnowledgeMeta:(KnowledgeMeta *)knowledgeMeta;

@end
