//
//  VideoDownloadItem.m
//  ebooksystem
//
//  Created by wanghaoyu on 14/12/9.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "VideoDownloadItem.h"
#import "IADownloadManager.h"
#import "IASequentialDownloadManager.h"
#import "LogUtil.h"


@interface VideoDownloadItem() <IADownloadManagerDelegate,IASequentialDownloadManagerDelegate>


@end

@implementation VideoDownloadItem
//初始化videoDownloadItem对象
- (VideoDownloadItem *)initWithItemId:(NSString *)itemId andTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath anddecodePassword:(NSString *)decodePassword
{
    self.itemId = itemId;
    self.title = title;
    self.desc = desc;
    self.downloadUrl = downloadUrl;
    self.savePath = savePath;
    self.createTime = [NSDate date];
    self.decodePassword = decodePassword;
    return self;
}

- (BOOL)startDownload
{
    [IADownloadManager downloadItemWithURL:self.downloadUrl useCache:YES saveToPath:self.savePath];
    [IADownloadManager attachListener:self toURL:self.downloadUrl];
    self.startTime = [NSDate date];
    return YES;
}

- (BOOL)stopDownload
{
    [IADownloadManager stopDownloadingItemWithURL:self.downloadUrl];
    [IADownloadManager detachListener:self];
    self.endTime = [NSDate date];
    return YES;
}

- (BOOL)downloadFinished
{
    return _downladFinished;
}

#pragma mark IADownLoadManager delegate
//IADownloadManager的代理方法，在这两个方法体中触发VideoDownloadItem的delegate
- (void)downloadManagerDidProgress:(float)progress
{
    self.downloadProgress = progress;
    [self.videoDownloadDelegate videoDownloadItem:self didProgress:progress];
    
}
//这里可以根据success值来判断是否下载成功（下载完成有两种方式：1、下载成功 2、下载失败）。
- (void)downloadManagerDidFinish:(BOOL)success response:(id)response
{
    self.downladFinished = YES;
    [IADownloadManager detachListener:self];
    [self.videoDownloadDelegate videoDownloadItem:self didFinshed:self.downladFinished response:response];
    
}
#pragma mark IASequentialDOwnloadManager delegate
- (void)sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(int)index
{
    
}
- (void)sequentialManagerProgress:(float)progress atIndex:(int)index
{
    
}
@end
