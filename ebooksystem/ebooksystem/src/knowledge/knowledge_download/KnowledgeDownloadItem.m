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

#import "LogUtil.h"



@interface KnowledgeDownloadItem()<IADownloadManagerDelegate, IASequentialDownloadManagerDelegate> {
    
}

@end




@implementation KnowledgeDownloadItem

@synthesize delegate = _delegate;
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

@synthesize tag = _tag;


#pragma mark - properties
// 下载进度. 50%中的数字50;
- (NSNumber *)downloadProgress {
//    if([self.totalSize doubleValue] > 0) {
//        _downloadProgress = [NSNumber numberWithDouble:[self.downloadSize doubleValue] * 100 / [self.totalSize doubleValue]];
//    }
//    else {
//        _downloadProgress = 0;
//    }
    
    NSNumber *progress = [[NSNumber alloc] initWithDouble:([_downloadProgress doubleValue] * 100.0)];
    return progress;
}

// 是否已下载完成
- (BOOL)downladFinished {
//    return ([self.downloadProgress intValue] >= 100);
    return _downladFinished;
}

#pragma mark - init
- (KnowledgeDownloadItem *)initWithItemId:(NSString *)itemId andTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath andTag:(NSString *)tag {
    self.itemId = itemId;
    self.title = title;
    self.desc = desc;
    self.downloadUrl = downloadUrl;
    self.savePath = savePath;
    
    self.createTime = [NSDate date];
    
    self.tag = tag;
    
    return self;
}

#pragma mark - download
- (BOOL)startDownload {
    [IADownloadManager downloadItemWithURL:self.downloadUrl useCache:YES saveToPath:self.savePath];
    
    [IADownloadManager attachListener:self toURL:self.downloadUrl];
    
    self.startTime = [NSDate date];
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
    
    self.endTime = [NSDate date];
    return YES;
}

- (BOOL)cancelDownload {
    [self stopDownload];
    self.endTime = [NSDate date];
    
    return YES;
}

#pragma mark - IADownloadManagerDelegate methods
- (void) downloadManagerDidProgress:(float)progress {
    self.downloadProgress = [NSNumber numberWithFloat:progress];
//    LogDebug(@"download item, id %@, title %@, progress: %@", self.itemId, self.title, self.downloadProgress);
    
    // 通知delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(knowledgeDownloadItem:didProgress:)]) {
        [self.delegate knowledgeDownloadItem:self didProgress:progress];
    }
}

- (void) downloadManagerDidFinish:(BOOL)success response:(id)response {
    if (success) {
        self.downloadSize = self.totalSize;
        self.downladFinished = YES;
//        LogDebug(@"download item, id %@, title %@, finished", self.itemId, self.title);
        [IADownloadManager detachObjectFromListening:self];
    }
    
    self.endTime = [NSDate date];
    
    // 通知delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(knowledgeDownloadItem:didFinish:response:)]) {
        [self.delegate knowledgeDownloadItem:self didFinish:success response:response];
    }
}

#pragma mark - IASequentialDownloadManagerDelegate methods
- (void) sequentialManagerProgress:(float)progress atIndex:(int)index {
    
}
- (void) sequentialManagerDidFinish:(BOOL)success response:(id)response atIndex:(int)index {
    
}


@end
