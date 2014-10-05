//
//  Config.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDataConfig.h"
#import "DrawableConfig.h"


@interface Config : NSObject

#pragma mark - knowledge data
// knowledge data config
@property(nonatomic, strong) KnowledgeDataConfig* knowledgeDataConfig;

#pragma mark - drawable
// drawable config
@property(nonatomic, strong) DrawableConfig* drawableConfig;

#pragma mark - singleton
// singleton
+ (Config *)instance;


@end
