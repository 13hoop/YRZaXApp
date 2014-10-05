//
//  KnowledgeDownloadManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDownloadItem.h"

@interface KnowledgeDownloadManager : NSObject

#pragma mark - singleton
// singleton
+ (KnowledgeDownloadManager *)instance;

#pragma mark - download
// 开始下载
- (BOOL)startDownload:(KnowledgeDownloadItem *)downloadItem;
// 暂停下载
- (BOOL)pauseDownloadWithId:(NSString *)downloadItemId;
// 恢复下载
- (BOOL)resumeDownloadWithId:(NSString *)downloadItemId;
// 停止下载
- (BOOL)stopDownloadWithId:(NSString *)downloadItemId;
// 取消下载
- (BOOL)cancelDownloadWithId:(NSString *)downloadItemId;


#pragma mark - test
// test
- (void)test;

@end
