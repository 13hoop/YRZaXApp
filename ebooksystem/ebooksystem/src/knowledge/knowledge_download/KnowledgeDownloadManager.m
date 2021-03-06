//
//  KnowledgeDownloadManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDownloadManager.h"

#import "UUIDUtil.h"
#import "LogUtil.h"
#import "NSUserDefaultUtil.h"


@interface KnowledgeDownloadManager() <KnowledgeDownloadItemDelegate> {
    
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

#pragma mark - sync download
- (BOOL)directDownloadWithUrl:(NSURL *)url andSavePath:(NSString *)savePath {
    NSError *error = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data == nil) {
        LogError(@"[KnowledgeDownloadManager-directDownloadWithUrl:andSavePath:] failed to download url: %@, error: %@", url, error.localizedDescription);
        return NO;
    }
    
    NSString *parentPath = [savePath stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:parentPath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL ret = [data writeToFile:savePath options:NSDataWritingAtomic error:&error];
    if (!ret) {
        LogError(@"[KnowledgeDownloadManager-directDownloadWithUrl:andSavePath:] failed to write to file: %@, error: %@", savePath, error);
    }
    return ret;
}


#pragma mark - async download
- (KnowledgeDownloadItem *)getDownloadItemById:(NSString *)itemId {
    if (itemId == nil) {
        return nil;
    }
    
    for(id key in [self.downloadItems allKeys]) {
        /*
        if (key != itemId) {
            continue;
        }
         */
        if ([key isEqualToString:itemId] == NO) {
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

- (BOOL)startDownloadWithTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath andTag:(NSString *)tag {
    // 准备下载目录
    NSString *parentSavePath = [savePath stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:parentSavePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentSavePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 创建KnowledgeDownloadItem
//    NSString *itemId = [NSString stringWithFormat:@"%@", [UUIDUtil getUUID]];
    NSString *itemId = [NSString stringWithFormat:@"%@",title];//将itemId设置成为具体下载的书籍的Id
   
    KnowledgeDownloadItem *downloadItem = [[KnowledgeDownloadItem alloc] initWithItemId:itemId andTitle:title andDesc:desc andDownloadUrl:downloadUrl andSavePath:savePath andTag:tag];
    //设置了一个可变字典类型的downloadItems属性，key:value(itemId:download对象)
    [self.downloadItems setObject:downloadItem forKey:downloadItem.itemId];
    
    // set delegate
    [downloadItem setDelegate:self];
    
    // 启动下载
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


#pragma mark - KnowledgeDownloadItemDelegate methods

// 下载进度
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(knowledgeDownloadItem:didProgress:)]) {
        [self.delegate knowledgeDownloadItem:downloadItem didProgress:progress];
    }
}

// 下载成功/失败
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didFinish:(BOOL)success response:(id)response {
    if (self.delegate && [self.delegate respondsToSelector:@selector(knowledgeDownloadItem:didFinish:response:)]) {
        [self.delegate knowledgeDownloadItem:downloadItem didFinish:success response:response];
    }
    
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
