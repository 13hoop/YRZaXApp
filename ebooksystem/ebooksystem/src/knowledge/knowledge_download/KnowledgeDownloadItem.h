//
//  KnowledgeDownloadItem.h
//  ebooksystem
//
//  Created by zhenghao on 10/3/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KnowledgeDownloadItem;


@protocol KnowledgeDownloadItemDelegate <NSObject>

@optional
// 下载进度
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress;
// 下载成功/失败
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didFinish:(BOOL)success response:(id)response;

@end


@interface KnowledgeDownloadItem : NSObject

#pragma mark - properties
// delegate
@property (nonatomic, copy) id<KnowledgeDownloadItemDelegate> delegate;


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

// tag: 用于存储额外信息. 本app中, 用于存储zip的password
@property (nonatomic, copy) NSString *tag;

#pragma mark - methods
#pragma mark - init
- (KnowledgeDownloadItem *)initWithItemId:(NSString *)itemId andTitle:(NSString *)title andDesc:(NSString *)desc andDownloadUrl:(NSURL *)downloadUrl andSavePath:(NSString *)savePath andTag:(NSString *)tag;

#pragma mark - download
- (BOOL)startDownload;
- (BOOL)pauseDownload;
- (BOOL)resumeDownload;
- (BOOL)stopDownload;
- (BOOL)cancelDownload;

@end
