//
//  StatisticsManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "StatisticsManager.h"

#import "MobClick.h"


#import "AppUtil.h"




@interface StatisticsManager ()

#pragma mark - properties



#pragma mark - methods
// 初始化友盟相关内容
- (void)initUmeng;

@end




@implementation StatisticsManager

@synthesize appKeyFromUmeng = _appKeyFromUmeng;
@synthesize channel = _channel;


#pragma mark - properties
// app key, from umeng
- (NSString *)appKeyFromUmeng {
    if (_appKeyFromUmeng == nil) {
        _appKeyFromUmeng = @"543dea72fd98c5fc98004e08";
    }
    
    return _appKeyFromUmeng;
}

// channel
- (NSString *)channel {
    if (_channel == nil) {
        _channel = @"";
    }
    
    return _channel;
}


#pragma mark - singleton
+ (StatisticsManager *)instance {
    static StatisticsManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[StatisticsManager alloc] init];
    });
    
    return sharedInstance;

}

#pragma mark - init

// 初始化友盟相关内容
- (void)initUmeng {
    [MobClick startWithAppkey:self.appKeyFromUmeng reportPolicy:BATCH channelId:self.channel];
    
    // 1. set app version
    NSString *appVersion = [AppUtil getAppVersionStr];
    [MobClick setAppVersion:appVersion];
    
    // 2. check update
    [MobClick checkUpdate:@"发现新版本" cancelButtonTitle:@"忽略" otherButtonTitles:@"更新"];
    
    // 3. check online config
    {
//        //在线参数配置
//        [MobClick updateOnlineConfig];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    }
}

#pragma mark - statistics
// page start
- (void)beginLogPageView:(NSString *)pageName {
    [MobClick beginLogPageView:pageName];
}

// page end
- (void)endLogPageView:(NSString *)pageName {
    [MobClick endLogPageView:pageName];
}

// event
- (void)event:(NSString *)eventId label:(NSString *)label {
    [MobClick event:eventId label:label];
}

#pragma mark - update
// check update
- (void)checkUpdate {
    [MobClick checkUpdate:@"发现新版本" cancelButtonTitle:@"忽略" otherButtonTitles:@"更新"];
}

@end
