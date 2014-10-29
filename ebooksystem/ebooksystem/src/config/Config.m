//
//  Config.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "Config.h"

@interface Config ()

#pragma mark - methods
// 加载配置文件
- (BOOL)loadConfigFile;


@end




@implementation Config

@synthesize channel = _channel;


#pragma mark - singleton
+ (Config *)instance {
    static Config *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
        [instance loadConfigFile];
    });
    
    return instance;
}

// 加载配置文件
- (BOOL)loadConfigFile {
    NSString *confFilepath = [NSString stringWithFormat:@"%@/%@/%@/%@", [[NSBundle mainBundle] resourcePath], @"assets", @"conf", @"ebooksystem_conf.plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:confFilepath];
    if (dict) {
        _channel = (NSString *)[dict objectForKey:@"channel"];
    }
    
    return YES;
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

#pragma mark - user
// user config
- (UserConfig *)userConfig {
    return [UserConfig instance];
}

#pragma mark - update
// update config
- (UpdateConfig *)updateConfig {
    return [UpdateConfig instance];
}

#pragma mark - error
// error config
- (ErrorConfig *)errorConfig {
    return [ErrorConfig instance];
}


@end
