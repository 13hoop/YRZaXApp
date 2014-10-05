//
//  Config.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "Config.h"

@implementation Config

@synthesize knowledgeDataConfig = _knowledgeDataConfig;
@synthesize drawableConfig = _drawableConfig;

#pragma mark - singleton
+ (Config *)instance {
    static Config *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - knowledge data config
- (KnowledgeDataConfig *)knowledgeDataConfig {
    if (_knowledgeDataConfig == nil) {
        _knowledgeDataConfig = [KnowledgeDataConfig instance];
    }
    
    return _knowledgeDataConfig;
}

#pragma mark - drawable config
- (DrawableConfig *)drawableConfig {
    if (_drawableConfig == nil) {
        _drawableConfig = [DrawableConfig instance];
    }
    
    return _drawableConfig;
}

@end
