//
//  Config.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppConfig.h"
#import "KnowledgeDataConfig.h"
#import "DrawableConfig.h"
#import "WebConfig.h"
#import "UserConfig.h"
#import "UpdateConfig.h"
#import "ErrorConfig.h"



@interface Config : NSObject

#pragma mark - properties



#pragma mark - singleton
// singleton
+ (Config *)instance;

#pragma mark - app
// app config
- (AppConfig *)appConfig;

#pragma mark - knowledge data
// knowledge data config
- (KnowledgeDataConfig *)knowledgeDataConfig;

#pragma mark - drawable
// drawable config
- (DrawableConfig *)drawableConfig;

#pragma mark - web
// web config
- (WebConfig *)webConfig;

#pragma mark - user
// user config
- (UserConfig *)userConfig;

#pragma mark - update
// update config
- (UpdateConfig *)updateConfig;

#pragma mark - error
// error config
- (ErrorConfig *)errorConfig;

@end
