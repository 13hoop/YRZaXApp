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

#import "DateUtil.h"
#import "LogUtil.h"




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
    NSURL *url = [NSURL URLWithString:[[Config instance].updateConfig.urlForCheckUpdate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // 下载目录
    NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
    NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, @"update_info", [DateUtil timestamp]];
    
    
    BOOL ret = [[KnowledgeDownloadManager instance] directDownloadWithUrl:url andSavePath:savePath];
    if (!ret) {
        LogError(@"[UpdateManager-checkUpdate] failed to download update info file");
        return NO;
    }
    
    
    return YES;
}



@end
