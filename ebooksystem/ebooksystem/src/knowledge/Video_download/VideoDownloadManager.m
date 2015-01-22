//
//  VideoDownloadManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 14/12/9.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "VideoDownloadManager.h"

@interface VideoDownloadManager () <VideoDownloadItemDelegate>

@property (nonatomic,strong) NSMutableDictionary *videoDownloadItems;
//根据itemId从可变字典中获取到对应item对象。
- (VideoDownloadItem *)getVideoDownloadItemWithItemId:(NSString *)itemId;
@end

@implementation VideoDownloadManager
//初始化可变字典VideoDownloadManager
- (NSMutableDictionary *)videoDownloadItems {
    if (_videoDownloadItems == nil) {
        _videoDownloadItems = [[NSMutableDictionary alloc] init];
    }
    
    return _videoDownloadItems;
}

//单例
+ (VideoDownloadManager*)shareInstance
{
    static VideoDownloadManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}
//根据itemId从可变字典中获取到对应item对象
- (VideoDownloadItem *)getVideoDownloadItemWithItemId:(NSString *)itemId
{
    if (itemId == nil) {
        return nil;
    }
    VideoDownloadItem *item = [self.videoDownloadItems objectForKey:itemId];
    if (item) {
        return item;
    }
    else{
        return nil;
    }
}

- (BOOL)startDownloadWithTitle:(NSString *)title andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)path andDesc:(NSString *)des andDecodePassword:(NSString *)password andItemId:(NSString *)itemId
{
    //（1）下载地址
    NSString *parentSavePath = [path stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:parentSavePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentSavePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //（2）实例化下载对象
    VideoDownloadItem *item = [[VideoDownloadItem alloc] initWithItemId:itemId andTitle:title andDesc:des andDownloadUrl:downloadUrl andSavePath:path anddecodePassword:password];
    //遵守代理协议
    item.videoDownloadDelegate = self;
    [self.videoDownloadItems setObject:item forKey:itemId];
    //（3）下载
    VideoDownloadItem *itemExit = [self.videoDownloadItems objectForKey:itemId];
    if (itemExit) {
        return [itemExit startDownload];
    }
    else{
        return NO;
    }
}

- (BOOL)stopDownloadWithId:(NSString *)downloadItemId
{
    VideoDownloadItem *item = [self.videoDownloadItems objectForKey:downloadItemId];
    if (item) {
        return [item stopDownload];
    }
    else{
        return NO;
    }
}

#pragma mark videoDownloadItem delegate
- (void)videoDownloadItem:(VideoDownloadItem *)videoDownloadItem didFinshed:(BOOL)isSuccess response:(id)response
{
    [self.videoDownloadManagerDelegate videoDownloadManagerWithDownLoadItem:videoDownloadItem didFinshed:isSuccess response:response];
    
}

- (void)videoDownloadItem:(VideoDownloadItem *)videoDownloadItem didProgress:(float)progress
{
    [self.videoDownloadManagerDelegate videoDownloadManagerWithDownLoadItem:videoDownloadItem didProgress:progress];
}
@end
