//
//  KnowledgeDownloadManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDownloadItem.h"

@class KnowledgeDownloadManager;


@protocol KnowledgeDownloadManagerDelegate <NSObject>

@optional
// 下载进度
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress;
// 下载成功/失败
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didFinish:(BOOL)success response:(id)response;

@end




@interface KnowledgeDownloadManager : NSObject

#pragma mark - delegate
@property (nonatomic, retain) id<KnowledgeDownloadManagerDelegate> delegate;

#pragma mark - singleton
// singleton
+ (KnowledgeDownloadManager *)instance;

#pragma mark - sync download
- (BOOL)directDownloadWithUrl:(NSURL *)url andSavePath:(NSString *)savePath;

#pragma mark - async download
// 开始下载
- (BOOL)startDownload:(KnowledgeDownloadItem *)downloadItem;
- (BOOL)startDownloadWithTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath andTag:(NSString *)tag;

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
