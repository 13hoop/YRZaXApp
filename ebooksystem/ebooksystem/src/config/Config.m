//
//  Config.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "Config.h"

@implementation Config


#pragma mark - singleton
+ (Config *)instance {
    static Config *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - app
// app config
- (AppConfig *)appConfig {
    return [AppConfig instance];
}

#pragma mark - knowledge data config
- (KnowledgeDataConfig *)knowledgeDataConfig {
    return [KnowledgeDataConfig instance];
}

#pragma mark - drawable config
- (DrawableConfig *)drawableConfig {
    return [DrawableConfig instance];
}

#pragma mark - web config
// web config
- (WebConfig *)webConfig {
    return [WebConfig instance];
}

@end
