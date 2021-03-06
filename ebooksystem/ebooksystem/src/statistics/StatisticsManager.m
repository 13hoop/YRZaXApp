//
//  StatisticsManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "StatisticsManager.h"

#import "MobClick.h"

#import "Config.h"


#import "AppUtil.h"

#import "LogUtil.h"

@interface StatisticsManager ()

#pragma mark - properties



#pragma mark - methods
// 初始化友盟相关内容
- (void)initUmeng;

@end




@implementation StatisticsManager

@synthesize appKeyFromUmeng = _appKeyFromUmeng;


#pragma mark - properties
// app key, from umeng
- (NSString *)appKeyFromUmeng {
    if (_appKeyFromUmeng == nil) {
        _appKeyFromUmeng = @"543dea72fd98c5fc98004e08";
    }
    
    return _appKeyFromUmeng;
}

#pragma mark - singleton
+ (StatisticsManager *)instance {
    static StatisticsManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[StatisticsManager alloc] init];
        [sharedInstance initUmeng];
    });
    
    return sharedInstance;

}

#pragma mark - init

// 初始化友盟相关内容
- (void)initUmeng {
    [MobClick startWithAppkey:self.appKeyFromUmeng reportPolicy:BATCH channelId:[Config instance].appConfig.channel];
    
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
    
    // 4. 禁用错误分析
//    [MobClick setCrashReportEnabled:NO];
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




//统计更新
- (void)statisticWithUrl:(NSString *)url {
    NSError *error = nil;
    NSURL *statictisUrl = [NSURL URLWithString:url];
//    NSURLRequest *request = [NSURLRequest requestWithURL:statictisUrl];
    
    
    NSString *contentType = @"text/html; charset=utf-8";
    NSString *userAgent = [Config instance].webConfig.userAgent;//取得UA
    NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] init];
    [requestHeaders setValue:contentType forKey:@"Content-Type"];
    [requestHeaders setValue:@"text/html" forKey:@"Accept"];
    [requestHeaders setValue:@"no-cache" forKey:@"Cache-Control"];
    [requestHeaders setValue:@"no-cache" forKey:@"Pragma"];
    [requestHeaders setValue:@"close" forKey:@"Connection"];
    if (userAgent != nil && userAgent.length > 0 ) {
        [requestHeaders setValue:userAgent forKey:@"User-Agent"];
    }
    
    
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:statictisUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [mutableRequest setAllHTTPHeaderFields:requestHeaders];
    //同步
//    NSData *data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:nil error:&error];
    //异步
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:mutableRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            LogError (@"[StatisticsManager - statisticWithUrl] statistic failed with error:%@",error.localizedDescription);
        }
        
    }];
}
//按照下载和更新来区分统计的url
- (void)statisticDownloadAndUpdateWithBookId:(NSString *)bookId andSuccess:(NSString *)successStr {
   
    NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    NSString *BookPath = [NSString stringWithFormat:@"%@/%@",knowledgeDataInDocument,bookId];
    BOOL BookExist = [[NSFileManager defaultManager] fileExistsAtPath:BookPath];
    NSString *updateUrl = nil;
    if (!BookExist) {//书籍不存在，说明为非更新
        
        updateUrl = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=download&k=start&v=1&book_id=%@",bookId];
        
        if ([successStr isEqualToString:@"succ"]) {
            updateUrl = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=download&k=succ&v=1&book_id=%@",bookId];
            
        }
    
        if ([successStr isEqualToString:@"fail"]) {
            updateUrl = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=download&k=fail&v=1&book_id=%@",bookId];
            
        }
    
        
    
        
    }
    else {
        
        updateUrl = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=update&k=start&v=1&book_id=%@",bookId];
        
        if ([successStr isEqualToString:@"succ"]) {
            updateUrl = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=update&k=succ&v=1&book_id=%@",bookId];
            
        }
        if ([successStr isEqualToString:@"fail"]) {
            updateUrl = [NSString stringWithFormat:@"http://log.zaxue100.com/pv.gif?t=update&k=fail&v=1&book_id=%@",bookId];
            
        }
        
    }
    
    
    NSError *error = nil;
    NSURL *statictisUrl = [NSURL URLWithString:updateUrl];
//    NSURLRequest *request = [NSURLRequest requestWithURL:statictisUrl];
    
    NSString *contentType = @"text/html; charset=utf-8";
    NSString *userAgent = [Config instance].webConfig.userAgent;//取得UA
    NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] init];
    [requestHeaders setValue:contentType forKey:@"Content-Type"];
    [requestHeaders setValue:@"text/html" forKey:@"Accept"];
    [requestHeaders setValue:@"no-cache" forKey:@"Cache-Control"];
    [requestHeaders setValue:@"no-cache" forKey:@"Pragma"];
    [requestHeaders setValue:@"close" forKey:@"Connection"];
    if (userAgent != nil && userAgent.length > 0 ) {
        [requestHeaders setValue:userAgent forKey:@"User-Agent"];
    }
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:updateUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [mutableRequest setAllHTTPHeaderFields:requestHeaders];
    
    
//    NSData *data = [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:nil error:&error];
    
    //异步请求
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:mutableRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            LogError (@"[StatisticsManager - statisticWithUrl] statistic failed with error:%@",error.localizedDescription);
        }

    }];
    
    
}





@end
