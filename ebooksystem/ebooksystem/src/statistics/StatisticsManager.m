//
//  StatisticsManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "StatisticsManager.h"

#import "MobClick.h"


@implementation StatisticsManager

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
//- (void)UmengMethod
//{
//    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:BATCH channelId:@""];
//    //Xcode4及以上的版本的version标识的取值--
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
//    //（1）多渠道完成自动更新
//    [MobClick checkUpdate];
//    //（2）使用这个方法，这些方法已经设置好（在弹出的AlertView中点击按钮就会实现相应的方法）
//    [MobClick checkUpdate:@"新版本" cancelButtonTitle:@"取消" otherButtonTitles:@"到APP Store中下载新版本"];
//    //(3)自定义的方式来完成
//    [MobClick checkUpdateWithDelegate:self selector:@selector(update:)];
//    
//    //在线参数配置
//    [MobClick updateOnlineConfig];  //在线参数配置
//    
//    //    1.6.8之前的初始化方法
//    //    [MobClick setDelegate:self reportPolicy:REALTIME];  //建议使用新方法
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
//    
//    
//}

#pragma mark - statistics
- (BOOL)pageStatisticWithEvent:(NSString *)eventName andArgs:(NSString *)args {
    if (eventName == nil || eventName.length <= 0) {
        return NO;
    }
    
    [MobClick event:eventName label:args];
    
    return YES;
}

@end
