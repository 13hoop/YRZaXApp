//
//  KnowledgeDownloadItem.m
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDownloadItem.h"
#import "IADownloadManager.h"
#import "IASequentialDownloadManager.h"

@interface KnowledgeDownloadItem()<IADownloadManagerDelegate, IASequentialDownloadManagerDelegate> {
    
}

- (void)onDownloadProgress:(float)progress withUrl:(NSURL *)url;
- (void)onDownloadComplete:(BOOL)success response:(id)response;

@end

@implementation KnowledgeDownloadItem

@synthesize itemId = _itemId;
@synthesize title = _title;
@synthesize desc = _desc;

@synthesize downloadUrl = _downloadUrl;
@synthesize savePath = _savePath;

@synthesize totalSize = _totalSize;
@synthesize downloadSize = _downloadSize;
@synthesize downloadProgress = _downloadProgress;
@synthesize downladFinished = _downladFinished;

@synthesize createTime = _createTime;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

#pragma mark - properties
// 下载进度. 50%中的数字50;
- (NSNumber *)downloadProgress {
    if([self.totalSize doubleValue] > 0) {
        _downloadProgress = [NSNumber numberWithDouble:[self.downloadSize doubleValue] * 100 / [self.totalSize doubleValue]];
    }
    else {
        _downloadProgress = 0;
    }
    
    return _downloadProgress;
}

// 是否已下载完成
- (BOOL)downladFinished {
    return ([self.downloadProgress intValue] >= 100);
}

#pragma mark - download
- (BOOL)startDownload {
    [IADownloadManager downloadItemWithURL:self.downloadUrl useCache:YES saveToPath:self.savePath];
    
    [IADownloadManager attachListenerWithObject:self
                                  progressBlock:^(float progress, NSURL *url) {
                                      [self onDownloadProgress:progress withUrl:url];
                                  }
                                completionBlock:^(BOOL success, id response) {
                                    [self onDownloadComplete:success response:response];
                                } toURL:self.downloadUrl];
    
    
    return YES;
}

- (BOOL)pauseDownload {
    [IADownloadManager stopDownloadingItemWithURL:self.downloadUrl];
    return YES;
}

- (BOOL)resumeDownload {
    [IADownloadManager downloadItemWithURL:self.downloadUrl useCache:YES saveToPath:self.savePath];
    return YES;
}

- (BOOL)stopDownload {
    [IADownloadManager stopDownloadingItemWithURL:self.downloadUrl];
    [IADownloadManager detachObjectFromListening:self];
    return YES;
}

- (BOOL)cancelDownload {
    [self stopDownload];
    return YES;
}

#pragma mark - download callback
- (void)onDownloadProgress:(float)progress withUrl:(NSURL *)url {
    self.downloadSize = [NSNumber numberWithFloat:progress];
}

- (void)onDownloadComplete:(BOOL)success response:(id)response {
    if (success) {
        self.downloadSize = self.totalSize;
    }
}

@end
