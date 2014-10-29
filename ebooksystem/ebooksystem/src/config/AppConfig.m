//
//  AppConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/20/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "AppConfig.h"

@interface AppConfig ()

#pragma mark - methods
// 加载配置文件
- (BOOL)loadConfigFile;

@end

@implementation AppConfig

@synthesize channel = _channel;
@synthesize appNameForCheckUpdate = _appNameForCheckUpdate;

@synthesize appVersionNum = _appVersionNum;
@synthesize appMode = _appMode;


#pragma mark - properties

// app version in num
- (NSInteger)appVersionNum {
    return 1; // modify before release
}

// app mode
- (AppMode)appMode {
    return (AppMode)APP_WITH_FULL_DATA;
}



#pragma mark - methods
// singleton
+ (AppConfig *)instance {
    static AppConfig *instance = nil;
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
        _appNameForCheckUpdate = (NSString *)[dict objectForKey:@"app_name_for_check_update"];
    }
    
    return YES;
}


@end
