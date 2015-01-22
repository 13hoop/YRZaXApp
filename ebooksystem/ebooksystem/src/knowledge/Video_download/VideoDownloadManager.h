//
//  VideoDownloadManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 14/12/9.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDownloadItem.h"
@class VideoDownloadManager;


@protocol VideoDownloadManagerDelegate <NSObject>

- (void)videoDownloadManagerWithDownLoadItem:(VideoDownloadItem *)videoDownloadItem didProgress:(float)progress;
- (void)videoDownloadManagerWithDownLoadItem:(VideoDownloadItem *)videoDownloadItem didFinshed:(BOOL)isSuccess response:(id)response;
@end


@interface VideoDownloadManager : NSObject
//代理属性
@property (nonatomic,weak)id <VideoDownloadManagerDelegate> videoDownloadManagerDelegate;

#pragma mark singleton
+ (VideoDownloadManager *)shareInstance;
#pragma mark method
//init videoDownLoadItem && start download
- (BOOL)startDownloadWithTitle:(NSString *)title andDownloadUrl:(NSURL*)downloadUrl andSavePath:(NSString *)path andDesc:(NSString *)des andDecodePassword:(NSString *)password andItemId:(NSString *)itemId;
//stop && pause download
- (BOOL)stopDownloadWithId:(NSString *)downloadItemId;


@end
