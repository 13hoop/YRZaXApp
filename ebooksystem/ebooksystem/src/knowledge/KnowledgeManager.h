//
//  KnowledgeManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDownloadItem.h"

@protocol KnowledgeManagerDelegate;





@interface KnowledgeManager : NSObject

#pragma mark - properties
@property (nonatomic, retain) id<KnowledgeManagerDelegate> delegate;

#pragma mark - singleton
// singleton
+ (KnowledgeManager *)instance;


// init data
- (BOOL)knowledgeDataInited;

- (BOOL)initKnowledgeDataAsync;
- (BOOL)initKnowledgeDataSync;

// register meta.json to db
- (BOOL)registerDataFiles;


#pragma mark - methods for js call
// get page path 这个方法必须传一个参数,参数没有用，已经注掉。
//- (NSString *)getPagePath:(NSString *)pageId withDataStoreLocation:(NSString *)dataStoreLocation;
// H:这个方法可以分别加载在bundle中的路径和加载在sandBox中的路径
- (NSString *)getPagePath:(NSString *)pageId;

// local data fetch
- (NSString *)getLocalData:(NSString *)dataId;
// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSArray *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename;
// remote data fetch
- (BOOL)getRemoteData:(NSString *)dataId;

// check data update
- (BOOL)startCheckDataUpdate;

// local data search
- (NSString *)searchLocalData:(NSString *)searchId;

// get data status
- (NSString *)getDataStatus:(NSString *)dataId;

#pragma mark - test
// test
- (void)test;

//H:从服务器获取数据更新信息，并同本地版本比较，获取更新信息。
- (BOOL)getUpdateInfoFileFromServerAndUpdateDataBase;
//H:下载一本新书
- (BOOL)startDownloadDataManagerWithDataId:(NSString *)dataId;
//H:根据js传来的dataId，从数据库中将查询到的对应信息返还给js。（包括：dataId,dataStatus,update_info）
- (NSString *)getUpdateInfoFormDataBaseWithDataString:(NSString *)dataString;
@end





@protocol KnowledgeManagerDelegate <NSObject>

@optional
- (void)dataInitStartedWithResult:(BOOL)result andDesc:(NSString *)desc;
- (void)dataInitProgressChangedTo:(NSNumber *)progress withDesc:(NSString *)desc;
- (void)dataInitEndedWithResult:(BOOL)result andDesc:(NSString *)desc;
//主动检查更新时，若返回的URL为空，则触发代理，弹出对话框来提示用户。
- (void)isShouldUpdateWithUpdateMessage:(NSString *)updateMessage;
- (void)knowledgeDownloadManagerWithProgress:(float)progress andDownloadItem:(KnowledgeDownloadItem  *)downloadItem;
- (void)knowledgeDownloadManagerIsSuccess:(BOOL)isSuccess andDownloadItem:(KnowledgeDownloadItem *)downloadItem;
//H：将收集到的可以更新的版本信息数组通过代理传值
- (BOOL)returnUpdatableDataVersionInfoArrayManager:(NSArray *)updatableDataVersionInfoArray;
- (BOOL)returnPromptInformationToJSWithInformation:(NSString *)promptInfo;
@end