//
//  KnowledgeDataManager.h
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KnowledgeDownloadItem.h"

@class KnowledgeMetaEntity;


@protocol KnowledgeDataStatusDelegate <NSObject>

@optional
- (BOOL)knowledgeData:(NSString *)dataId downloadedToPath:(NSString *)dataPath successfully:(BOOL)succ;
- (BOOL)knowledgeDataAtPath:(NSString *)dataPath updatedSuccessfully:(BOOL)succ;
//H：主动检查更新信息的反馈结果，downloadUrl为空则触发该代理。
- (void)isShouldUpdateWithUpdateMessage:(NSString *)updateMessage;
//获取下载进度和下载成功失败结果
- (BOOL)DownLoadKnowledgedataWithProgress:(float)progress andDownloadItem:(KnowledgeDownloadItem *)downloadItem;
- (BOOL)DownLoadKnowledgedata:(BOOL)isSuccess andDownLoadItem:(KnowledgeDownloadItem *)downloadItem;
//服务器获取数据更新信息，同本地数据版本对比后，收集需要更新的数据。并将该数据集合通过代理的方式出给使用者
- (BOOL)returnUpdatableDataVersionInfo:(NSArray *)updatableDataVersionInfoArray;
//若是没有需要更新的信息，给js提示。--备用
- (BOOL)returnPromptInformationToJSWithInformation:(NSString *)promptInfo;

@end




@interface KnowledgeDataManager : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *lastError;

#pragma mark - delegate
@property (nonatomic, retain) id<KnowledgeDataStatusDelegate> dataStatusDelegate;





#pragma mark - singleton
+ (KnowledgeDataManager *)instance;

#pragma mark - copy data files
// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData;

#pragma mark - load data content
// load knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeMetaEntity *)knowledgeMetaEntity;

// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSArray *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename;

#pragma mark - download knowledge data
// start downloading
- (BOOL)startDownloadData:(NSString *)dataId;

#pragma mark - data update
// check data update, and apply update according to update mode
- (BOOL)startUpdateData;
// check data update, and auto apply update
- (BOOL)startUpdateData:(NSString *)dataId;






#pragma mark - search
// search data
- (NSArray *)searchData:(NSString *)searchId;

//H:controller中跳过knowledgeManager直接调用
- (void)startDownloadWithUrl:(NSURL*)downloadUrl andTitle:(NSString *)title andDesc:(NSString *)desc andWithTag:(NSString *)tag andSavePath:(NSString*)path;
//- (BOOL)startDownloadWithResponse:(ServerResponseOfKnowledgeData *)response;


//H:从服务器获取数据版本信息，同本地的版本信息对比，并更新到数据库
- (BOOL)getUpdateInfoFileFromServerAndUpdateDataBase;
//H:下载新书：
- (BOOL)startDownloadDataWithDataId:(NSString *)dataId;

#pragma mark - getBooklist

//2.0 get Book List
- (NSArray *)getBookList:(NSString *)bookCategory;

#pragma mark 检查数据是否可用
- (BOOL)checkIsAvailableWithFilePath:(NSString *)bookPath;



#pragma mark - stop 、pause download data
- (BOOL)stopDownloadData:(NSString *)dataId;
- (BOOL)pauseDownloadData:(NSString *)dataId;


@end
