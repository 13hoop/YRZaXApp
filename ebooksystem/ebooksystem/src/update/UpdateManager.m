//
//  UpdateManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UpdateManager.h"

#import "Config.h"

#import "KnowledgeDownloadManager.h"


#import "AppUtil.h"
#import "DateUtil.h"
#import "LogUtil.h"
#import "PathUtil.h"




@implementation UpdateManager


#pragma mark - singleton
+ (UpdateManager *)instance {
    static UpdateManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[UpdateManager alloc] init];
    });
    
    return sharedInstance;
    
}

#pragma mark - check update
- (BOOL)checkUpdate {
    // 启动后台任务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[[Config instance].updateConfig.urlForCheckUpdate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // 下载更新信息文件
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, @"update_info", [DateUtil timestamp]];
        
        BOOL ret = [[KnowledgeDownloadManager instance] directDownloadWithUrl:url andSavePath:savePath];
        if (!ret) {
            LogError(@"[UpdateManager-checkUpdate] failed to download update info file");
            return;
        }
        
        // 读取更新信息文件
        NSError *error = nil;
        NSString *updateInfoFileContents = [NSString stringWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:&error];
        if (updateInfoFileContents == nil || updateInfoFileContents.length <= 0) {
            LogError(@"[UpdateManager-checkUpdate] failed to read update info file: %@", savePath);
            return;
        }
        
        // 解析json
        JSONModelError *jsonModelError = nil;
        UpdateInfo *updateInfo = [[UpdateInfo alloc] initWithString:updateInfoFileContents usingEncoding:NSUTF8StringEncoding error:&jsonModelError];
        if (updateInfo == nil) {
            LogError(@"[UpdateManager-checkUpdate] failed to parse update info from : %@", updateInfoFileContents);
            return;
        }
        
        // 判断是否有更新
        if (updateInfo.appVersionStr != nil) {
            NSString *curAppVersion = [AppUtil getAppVersionStr];
            if (curAppVersion != nil) {
                BOOL updatable = ([curAppVersion compare:updateInfo.appVersionStr options:NSNumericSearch] == NSOrderedAscending);
                updateInfo.shouldUpdate = (updatable ? @"YES" : @"NO");
            }
        }
        
        [PathUtil deletePath:savePath];
        
        // 调用delegate方法
        if (self.delegate && [self.delegate respondsToSelector:@selector(onCheckUpdateResult:)]) {
            [self.delegate onCheckUpdateResult:updateInfo];
        }
    });
    
    return YES;
}


@end
