//
//  KnowledgeDownloadManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDownloadManager.h"
#import "UUIDUtil.h"


@interface KnowledgeDownloadManager() {
    
}


@property (nonatomic, copy)NSMutableDictionary *downloadItems;

- (KnowledgeDownloadItem *)getDownloadItemById:(NSString *)itemId;

@end

@implementation KnowledgeDownloadManager

@synthesize downloadItems = _downloadItems;

#pragma mark - properties
- (NSMutableDictionary *)downloadItems {
    if (_downloadItems == nil) {
        _downloadItems = [[NSMutableDictionary alloc] init];
    }
    
    return _downloadItems;
}

#pragma mark - singleton
// singleton
+ (KnowledgeDownloadManager *)instance {
    static KnowledgeDownloadManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - download
- (KnowledgeDownloadItem *)getDownloadItemById:(NSString *)itemId {
    if (itemId == nil) {
        return nil;
    }
    
    for(id key in [self.downloadItems allKeys]) {
        if (key != itemId) {
            continue;
        }
        
        KnowledgeDownloadItem *item = [self.downloadItems objectForKey:key];
        return item;
    }
    
    return nil;
}

// 开始下载
- (BOOL)startDownload:(KnowledgeDownloadItem *)downloadItem {
    if (downloadItem == nil || downloadItem.downloadUrl == nil) {
        return NO;
    }
    
    [self.downloadItems setObject:downloadItem forKey:downloadItem.itemId];
    return [downloadItem startDownload];
}

// 暂停下载
- (BOOL)pauseDownloadWithId:(NSString *)downloadItemId {
    KnowledgeDownloadItem *downloadItem = [self getDownloadItemById:downloadItemId];
    if (downloadItem == nil) {
        return NO;
    }
    
    return [downloadItem pauseDownload];
}

// 恢复下载
- (BOOL)resumeDownloadWithId:(NSString *)downloadItemId {
    KnowledgeDownloadItem *downloadItem = [self getDownloadItemById:downloadItemId];
    if (downloadItem == nil) {
        return NO;
    }
    
    return [downloadItem resumeDownload];
}

// 停止下载
- (BOOL)stopDownloadWithId:(NSString *)downloadItemId {
    KnowledgeDownloadItem *downloadItem = [self getDownloadItemById:downloadItemId];
    if (downloadItem == nil) {
        return NO;
    }
    
    return [downloadItem stopDownload];
}

// 取消下载
- (BOOL)cancelDownloadWithId:(NSString *)downloadItemId {
    KnowledgeDownloadItem *downloadItem = [self getDownloadItemById:downloadItemId];
    if (downloadItem == nil) {
        return NO;
    }
    
    return [downloadItem cancelDownload];
}


#pragma mark - test
// test
- (void)test {
    KnowledgeDownloadItem *downloadItem = [[KnowledgeDownloadItem alloc] init];
    downloadItem.itemId = [UUIDUtil getUUID];
    downloadItem.title = @"test download";
    downloadItem.desc = @"test download";
    downloadItem.downloadUrl = [NSURL URLWithString:@"http://www.wired.com/images_blogs/gadgetlab/2012/08/080612-APPLE-SCREENS-ICLOUD-001edit.jpg"];
    
    // 当前程序沙盒目录
    NSString *savePath = NSHomeDirectory();
    savePath = [savePath stringByAppendingPathComponent:@"Documents/test_download_item"];
    downloadItem.savePath = savePath;
    
    [self startDownload:downloadItem];
    
}

@end
