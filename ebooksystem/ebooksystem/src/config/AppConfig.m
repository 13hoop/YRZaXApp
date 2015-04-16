//
//  AppConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/20/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "AppConfig.h"

@interface AppConfig ()

#pragma mark - properties
@property (nonatomic, assign) BOOL isOnlineMode;
@property (nonatomic, copy) NSString *httpDomainForOnlineMode;
@property (nonatomic, copy) NSString *httpDomainForOfflineMode;

@property (nonatomic, copy) NSString *httpLogDomainForOnlineMode;

#pragma mark - methods
// 加载配置文件
- (BOOL)loadConfigFile;

@end

@implementation AppConfig

@synthesize isOnlineMode = _isOnlineMode;
@synthesize httpDomainForOnlineMode = _httpDomainForOnlineMode;
@synthesize httpDomainForOfflineMode = _httpDomainForOfflineMode;
@synthesize httpDomain = _httpDomain;
@synthesize httpDomainForLog = _httpDomainForLog;
@synthesize httpDomainForData = _httpDomainForData;

@synthesize httpLogDomainForOnlineMode = _httpLogDomainForOnlineMode;

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
        _isOnlineMode = (BOOL)[dict objectForKey:@"is_online_mode"];
        _httpDomainForOnlineMode = (NSString *)[dict objectForKey:@"http_domain_for_online_mode"];
        _httpDomainForOfflineMode = (NSString *)[dict objectForKey:@"http_domain_for_offline_mode"];
        _httpDomain = (_isOnlineMode ? _httpDomainForOnlineMode : _httpDomainForOfflineMode);
        
        _httpLogDomainForOnlineMode = (NSString *)[dict objectForKey:@"http_log_domain_for_online_mode"];
        _httpDomainForLog = (_isOnlineMode ? _httpLogDomainForOnlineMode : _httpDomainForOfflineMode);
        
        _httpDomainForData = (NSString *)[dict objectForKey:@"http_sdata_domain_for_online_mode"];
        
        _channel = (NSString *)[dict objectForKey:@"channel"];
        _appNameForCheckUpdate = (NSString *)[dict objectForKey:@"app_name_for_check_update"];
    }
    
    return YES;
}


@end
