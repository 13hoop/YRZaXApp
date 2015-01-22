//
//  VideoDownloadItem.h
//  ebooksystem
//
//  Created by wanghaoyu on 14/12/9.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VideoDownloadItem;


@protocol VideoDownloadItemDelegate <NSObject>

- (void)videoDownloadItem:(VideoDownloadItem*)videoDownloadItem didProgress:(float)progress;
- (void)videoDownloadItem:(VideoDownloadItem *)videoDownloadItem didFinshed:(BOOL)isSuccess response:(id)response;

@end

@interface VideoDownloadItem : NSObject

//代理属性
@property (nonatomic,weak)id <VideoDownloadItemDelegate>videoDownloadDelegate;

//设置itemId用来区分不同的下载任务
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
// 下载地址
@property (nonatomic, strong) NSURL *downloadUrl;
// 在本地的存储地址
@property (nonatomic, strong) NSString *savePath;

// 总大小, 字节
@property (nonatomic, assign) NSNumber *totalSize;
// 已下载大小, 字节
@property (nonatomic, assign) NSNumber *downloadSize;
// 下载进度
@property (nonatomic, assign) float downloadProgress;
// 是否已下载完成
@property (nonatomic, assign) BOOL downladFinished;

@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

// decodePassword 存储zip的password，以便以后下载视频时使用zip格式传输。
@property (nonatomic, copy) NSString *decodePassword;

#pragma mark download Item method

//init
- (VideoDownloadItem *)initWithItemId:(NSString *)itemId andTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath anddecodePassword:(NSString *)decodePassword;
//对IADownloadManager修改后只需要开始，停止两个方法。
- (BOOL)startDownload;
- (BOOL)stopDownload;
@end
