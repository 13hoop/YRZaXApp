//
//  KnowledgeDownloadItem.h
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KnowledgeDownloadItem : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

// 下载地址
@property (nonatomic, copy) NSURL *downloadUrl;
// 在本地的存储地址
@property (nonatomic, copy) NSString *savePath;

// 总大小, B
@property (nonatomic, copy) NSNumber *totalSize;
// 已下载大小, B
@property (nonatomic, copy) NSNumber *downloadSize;
// 下载进度. 50%中的数字50;
@property (nonatomic, copy) NSNumber *downloadProgress;
// 是否已下载完成
@property (nonatomic, assign) BOOL downladFinished;

@property (nonatomic, copy) NSDate *createTime;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *endTime;

#pragma mark - methods
#pragma mark - init
- (KnowledgeDownloadItem *)initWithItemId:(NSString *)itemId andTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath;

#pragma mark - download
- (BOOL)startDownload;
- (BOOL)pauseDownload;
- (BOOL)resumeDownload;
- (BOOL)stopDownload;
- (BOOL)cancelDownload;

@end
