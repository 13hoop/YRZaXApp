//
//  KnowledgeDataManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataManager.h"

#import "Config.h"

#import "KnowledgeMetaEntity.h"
#import "KnowledgeMetaManager.h"
#import "KnowledgeDataLoader.h"


#import "UserManager.h"
#import "KnowledgeDownloadManager.h"

#import "ZipArchive.h"

#import "PathUtil.h"
#import "DeviceUtil.h"
#import "MD5Util.h"
#import "CryptUtil.h"
#import "WebUtil.h"
#import "UUIDUtil.h"
#import "DateUtil.h"
#import "AppUtil.h"
#import "LogUtil.h"



@interface KnowledgeDataManager() <KnowledgeDownloadManagerDelegate>

#pragma mark - 数据下载
// 根据ServerResponseOfKnowledgeData, 启动下载更新
- (BOOL)startDownloadWithResponse:(ServerResponseOfKnowledgeData *)response;

// 下载完成后的后续操作, 包括: (1) 复制目录 (2) 注册数据
- (BOOL)processDownloadedDataPack:(KnowledgeDownloadItem *)downloadItem;

// 处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey;

// 添加或更新数据
- (BOOL)addOrReplaceData:(NSString *)metaFilePath;
// 删除数据
- (BOOL)deleteData:(NSString *)metaFilePath;

#pragma mark - 数据更新
// 解析dataVersion文件
- (NSArray *)parseDataVersionInfo:(NSString *)dataVersionFilePath;

// 确定可更新的数据集合
- (NSArray *)decideUpdatableData:(NSArray *)dataVersionInfoArray;

// 确定与指定数据相关的可更新的数据集合
- (NSArray *)decideUpdatableData:(NSArray *)dataVersionInfoArray forData:(NSString *)dataId;

// 获取各data的更新信息(数据的下载地址等)
- (ServerResponseOfKnowledgeData *)getDataUpdateInfo:(DataUpdateRequestInfo *)requestInfo;

#pragma mark - 数据检索
// decide searchable data ids
- (NSArray *)decideSearchableDataIds;

@end


@implementation KnowledgeDataManager

#pragma mark - properties
@synthesize lastError;


#pragma mark - singleton
+ (KnowledgeDataManager *)instance {
    static KnowledgeDataManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[KnowledgeDataManager alloc] init];
        
        [[KnowledgeDownloadManager instance] setDelegate:sharedInstance];
    });
    
    return sharedInstance;
}


#pragma mark - knowledge data operations
#pragma mark - copy data files
// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData {
    NSString *knowledgeDataRootPathInAssets = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    
    BOOL ret = [PathUtil copyFilesFromPath:(NSString *)knowledgeDataRootPathInAssets toPath:(NSString *)knowledgeDataRootPathInDocuments];
    
    return ret;
}

// load knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeMetaEntity *)knowledgeMetaEntity {
    if (knowledgeMetaEntity == nil || knowledgeMetaEntity.dataPath == nil || knowledgeMetaEntity.dataPath.length <= 0) {
        return nil;
    }
    
    NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@/%@", knowledgeDataRootPathInApp, knowledgeMetaEntity.dataPath, @"data.json"];
        
    // read file line by line
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
    if (fileContents == nil || fileContents.length <= 0) {
        LogError(@"[KnowledgeDataManager-loadKnowledgeData:] failed, data id: %@, file: %@, error: %@", knowledgeMetaEntity.dataId, fullFilePath, error.localizedDescription);
        return nil;
    }
    
    return fileContents;
}

// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSArray *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename {
    return [[KnowledgeDataLoader instance] getKnowledgeDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
}

#pragma mark - download knowledge data
// 启动下载数据
- (BOOL)startDownloadData:(NSString *)dataId {
    return [self startUpdateData:dataId];
}

// 数据包下载后的后续操作, 包括: 解包, 拷贝文件, 更新数据库等
- (BOOL)processDownloadedDataPack:(KnowledgeDownloadItem *)downloadItem {
    BOOL ret = YES;
    NSMutableArray *zippedDataFiles = [[NSMutableArray alloc] init];
    
    do {
        // check
        {
            if (downloadItem == nil || downloadItem.savePath == nil || downloadItem.savePath.length <= 0) {
                ret = NO;
                break;
            }
            
            BOOL isDir = NO;
            BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:downloadItem.savePath isDirectory:&isDir];
            if (!existed) {
                ret = NO;
                break;
            }
        }
        
        LogInfo(@"[KnowledgeDataManager-processDownloadedDataPack:] started, file: %@", downloadItem.savePath);
        
        // 1. 解包
        NSString *unpackPath = [NSString stringWithFormat:@"%@-unpack", downloadItem.savePath];
        {
            // 1.1 unzip
            // 分别尝试无密码和有密码两种unzip方式. 因: download时得到的zip包无密码, 而update得到的zip包有密码.
            NSMutableArray *passwords = [[NSMutableArray alloc] init];
            [passwords addObject:@""];
            if (downloadItem.tag != nil && downloadItem.tag.length > 0) {
                [passwords addObject:downloadItem.tag];
            }
            
            ZipArchive *za = [[ZipArchive alloc] init];
            
            for (NSString *password in passwords) {
                if (password == nil || password.length <= 0) {
                    ret = [za unzipOpenFile:downloadItem.savePath];
                }
                else {
                    ret = [za unzipOpenFile:downloadItem.savePath password:downloadItem.tag];
                }
                
                ret = [za unzipFileTo:unpackPath overwrite:YES];
                if (!ret) {
                    LogError(@"[KnowledgeDataManager:processDownloadedDataPack:] failed, since failed to unzip zip file: %@", downloadItem.savePath);
                    ret = NO;
                    continue; // 继续尝试下一password
                }
                
                // 1.2 check whether unzip path exists
                BOOL isDir = NO;
                BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackPath isDirectory:&isDir];
                if (existed) {
                    break; // 已解包成功
                }
                
                LogWarn(@"[KnowledgeDataManager-processDownloadedDataPack:] failed, since there is no unzip file after unzip. The zip file is: %@, and password is %@", downloadItem.savePath, (password == nil ? @"nil" : password));
                ret = NO;
            }
            
            // 1.2 check whether unzip path exists
            if (!ret) {
                LogError(@"[KnowledgeDataManager-processDownloadedDataPack:] failed to unzip file is: %@", downloadItem.savePath);
                ret = NO;
                break;
            }
            
            // 1.3 check md5, and collect zipped data files
            {
                NSError *error = nil;
                NSString *md5File = [NSString stringWithFormat:@"%@/%@", unpackPath, @"md5.txt"];
                NSString *md5FileContents = [NSString stringWithContentsOfFile:md5File encoding:NSUTF8StringEncoding error:&error];
                if (md5FileContents == nil || md5FileContents.length <= 0) {
                    LogError(@"[KnowledgeDataManager-processDownloadedDataPack:] failed, invalid md5 file. The zip file is: %@", downloadItem.savePath);
                    ret = NO;
                    break;
                }
                
                // check each file's md5
                NSArray *lines = [md5FileContents componentsSeparatedByString:@"\n"];
                if (lines == nil || lines.count <= 0) {
                    ret = NO;
                    break;
                }
                
                // 逐行解析
                NSEnumerator *enumerator = [lines objectEnumerator];
                NSString *curLine = nil;
                while ((curLine = [enumerator nextObject]) != nil) {
                    //                NSArray *fields = [curLine componentsSeparatedByString:@"\t"];
                    NSArray *fields = [curLine componentsSeparatedByString:@" "]; // md5.txt中的字段由空格分隔
                    if (fields == nil || fields.count < 2) {
                        continue;
                    }
                    
                    NSString *md5FromServer = [fields objectAtIndex:0];
                    NSString *filename = [NSString stringWithFormat:@"%@/%@", unpackPath, [fields objectAtIndex:fields.count - 1]];
                    
                    NSString *md5FromApp = [MD5Util md5ForFile:filename];
                    
                    if (![md5FromApp isEqualToString:md5FromServer]) {
                        LogError(@"[KnowledgeDataManager-processDownloadedDataPack:] failed, sice md5 check failed. The failed file is: %@", filename);
                        ret = NO;
                        break;
                    }
                    
                    [zippedDataFiles addObject:filename];
                }
            }
        }
        
        if (zippedDataFiles == nil || zippedDataFiles.count <= 0) {
            LogError(@"[KnowledgeDataManager-processDownloadedDataPack:] failed, since no zipped data files. The zip file is: %@", downloadItem.savePath);
            ret = NO;
            break;
        }
        
        
        // 2. 根据op.lst, 拷贝文件, 更新数据库
        {
            for (NSString *zippedDataFilename in zippedDataFiles) {
                // check
                if (zippedDataFilename == nil || zippedDataFilename.length <= 0) {
                    continue;
                }
                
                BOOL isDir = NO;
                BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackPath isDirectory:&isDir];
                if (!existed) {
                    continue;
                }
                
                // process
                ret = [self processZippedDataFile:zippedDataFilename withDecryptKey:downloadItem.tag];
                if (!ret) {
                    LogError(@"[KnowledgeDataManager-processDownloadedDataPack:] failed, since failed to process zipped data file: %@", zippedDataFilename);
                    ret = NO;
                    break;
                }
            }
        }
    } while (NO);
    
    // 3. 删除已下载的数据文件
    [PathUtil deletePath:downloadItem.savePath];
    LogInfo(@"[KnowledgeDataManager-processDownloadedDataPack:] deleted downloaded data file: %@", downloadItem.savePath);
    
    // 3. 返回
    LogInfo(@"[KnowledgeDataManager-processDownloadedDataPack:] end %@, file: %@", (ret ? @"successfully" : @"failed"), downloadItem.savePath);
    return ret;
}

// 处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey {
    BOOL ret = YES;
    
    NSString *unpackPath = [filename stringByDeletingLastPathComponent];
    NSString *unpackedDataPath = [filename stringByDeletingPathExtension];
    
    LogInfo(@"[KnowledgeDataManager-processZippedDataFile:] started, file: %@", filename);
    do {
        // 1. 解包
        {
            // 1.1 unzip
            ZipArchive *za = [[ZipArchive alloc] init];
            BOOL ret = [za unzipOpenFile:filename password:decryptedKey];
            if (!ret) {
                LogError(@"[KnowledgeDataManager-processZippedDataFile:] failed, since failed to open zip file: %@", filename);
                ret = NO;
                break;
            }
            
            ret = [za unzipFileTo:unpackPath overwrite:YES];
            if (!ret) {
                LogError(@"[KnowledgeDataManager-processZippedDataFile:] failed, since failed to unzip zip file: %@", filename);
                ret = NO;
                return NO;
            }
            
            // 1.2 check whether unzip path exists
            BOOL isDir = NO;
            BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackedDataPath isDirectory:&isDir];
            if (!existed) {
                LogError(@"[KnowledgeDataManager-processZippedDataFile:] failed, since there is no unzip file after unzip. The zip file is: %@", filename);
                ret = NO;
                break;
            }
        }
        
        // 2. 根据op.lst, 进行相应的操作
        NSString *operationFilename = @"op.lst";
        NSString *dataDirname = @"node";
        
        NSString *fullOperationFilename = [NSString stringWithFormat:@"%@/%@", unpackedDataPath, operationFilename];
        {
            NSError *error = nil;
            NSString *operationFileContents = [NSString stringWithContentsOfFile:fullOperationFilename encoding:NSUTF8StringEncoding error:&error];
            if (operationFileContents == nil || operationFileContents.length <= 0) {
                LogError(@"[KnowledgeDataManager-processZippedDataFile:] failed, invalid operation file: %@", fullOperationFilename);
                ret = NO;
                break;
            }
            
            // check each file's md5
            NSArray *lines = [operationFileContents componentsSeparatedByString:@"\n"];
            if (lines == nil || lines.count <= 0) {
                break;
            }
            
            // 逐行解析
            NSEnumerator *enumerator = [lines objectEnumerator];
            NSString *curLine = nil;
            while ((curLine = [enumerator nextObject]) != nil) {
                NSArray *fields = [curLine componentsSeparatedByString:@"\t"];
                if (fields == nil || fields.count < 3) {
                    continue;
                }
                
                NSString *dataName = [fields objectAtIndex:0];
                NSString *operationPath = [fields objectAtIndex:1];
                NSInteger operationType = [[fields objectAtIndex:2] intValue];
                
                NSString *fullMetaFilePath = [NSString stringWithFormat:@"%@/%@/%@/%@", unpackedDataPath, dataDirname, operationPath, [Config instance].knowledgeDataConfig.knowledgeMetaFilename];
                
                
                // 1.2 check whether meta file exists
                BOOL isDir = NO;
                BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:fullMetaFilePath isDirectory:&isDir];
                if (!existed) {
                    continue;
                }
                
                switch (operationType) {
                    case 0: // add or replace
                        [self addOrReplaceData:fullMetaFilePath];
                        break;
                        
                    case 1: // delete
                        [self deleteData:fullMetaFilePath];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    } while (NO);
    
    // 2. 删除unpacked文件夹
    [PathUtil deletePath:unpackPath];
    LogInfo(@"[KnowledgeDataManager] processZippedDataFile() deleted unpacked data path: %@", unpackPath);
    
    // 3. 返回
    LogInfo(@"[KnowledgeDataManager] processZippedDataFile() end %@, file: %@", (ret ? @"successfully" : @"failed"), filename);
    return ret;
}

// 添加或更新数据
- (BOOL)addOrReplaceData:(NSString *)metaFilePath {
    NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] loadKnowledgeMeta:metaFilePath];
    if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
        return NO;
    }
    
    BOOL ret = YES;
    
    for (id obj in knowledgeMetas) {
        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
        if (knowledgeMeta == nil) {
            continue;
        }
        
        NSArray *originalKnowledgeMetas = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:knowledgeMeta.dataId andDataType:DATA_TYPE_DATA_SOURCE];
        
        // add
        if (originalKnowledgeMetas == nil || originalKnowledgeMetas.count <= 0) {
            // 1. 复制文件夹
            NSString *fromPath = [metaFilePath stringByDeletingLastPathComponent];
            NSString *toPath = [NSString stringWithFormat:@"%@/%@", [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments, knowledgeMeta.dataPath ];
            
            ret = [PathUtil copyFilesFromPath:fromPath toPath:toPath];

            // 2. 修改数据状态及其它相关属性
            if (ret) {
                knowledgeMeta.DataStorageType = DATA_STORAGE_INTERNAL_STORAGE;
                knowledgeMeta.DataStatus = DATA_STATUS_UPDATE_COMPLETED;
                knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
                
                knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
                knowledgeMeta.updateTime = [NSDate date];
                
                ret = [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
            }
        }
        // replace
        else {
            // 1. 将数据状态修改为updating
            ret = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_IN_PROGRESS andDataStatusDescTo:nil forDataWithDataId:knowledgeMeta.dataId andType:DATA_TYPE_DATA_SOURCE];
            
            // 2. 替换文件夹
            NSString *fromPath = [metaFilePath stringByDeletingLastPathComponent];
            NSString *toPath = [NSString stringWithFormat:@"%@/%@", [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments, knowledgeMeta.dataPath ];
            
            ret = [PathUtil copyFilesFromPath:fromPath toPath:toPath];
            
            // 3. 修改数据状态及其它相关属性
            if (ret) {
                knowledgeMeta.DataStorageType = DATA_STORAGE_INTERNAL_STORAGE;
                knowledgeMeta.DataStatus = DATA_STATUS_UPDATE_COMPLETED;
                knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
                
                knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
                knowledgeMeta.updateTime = [NSDate date];
                
                ret = [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
            }
            else {
                ret = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_AVAIL andDataStatusDescTo:nil forDataWithDataId:knowledgeMeta.dataId andType:DATA_TYPE_DATA_SOURCE];
            }
        }
    }
    
    return ret;
}

// 删除数据
- (BOOL)deleteData:(NSString *)metaFilePath {
    NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] loadKnowledgeMeta:metaFilePath];
    if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
        return NO;
    }
    
    BOOL ret = YES;
    
    for (id obj in knowledgeMetas) {
        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
        if (knowledgeMeta == nil) {
            continue;
        }
        
        // 1. 将meta信息从coreData中删除
        ret = [[KnowledgeMetaManager instance] deleteKnowledgeMetaWithDataId:knowledgeMeta.dataId andDataType:DATA_TYPE_DATA_SOURCE];
        
        // 2. 将data文件删除
        if (ret) {
            NSString *dataPath = [NSString stringWithFormat:@"%@/%@", [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments, knowledgeMeta.dataPath ];
            ret = [PathUtil deletePath:dataPath];
        }
    }
    
    return ret;
}

#pragma mark - data update
// 根据ServerResponseOfKnowledgeData, 启动下载更新
- (BOOL)startDownloadWithResponse:(ServerResponseOfKnowledgeData *)response {
    if (response == nil || response.updateInfo == nil) {
        LogError(@"[KnowledgeDataManager-startDownloadUpdateWithResponse:] failed because of invalid server response");
        return NO;
    }
    
    if (response.updateInfo.status != 0) {
        LogError(@"[KnowledgeDataManager-startDownloadUpdateWithResponse:] failed because of invalid server response, status: %ld, message: %@", response.updateInfo.status, response.updateInfo.message);
        return NO;
    }
    
    if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
        LogError(@"[KnowledgeDataManager-startDownloadUpdateWithResponse:] failed because of invalid server response, no details");
        return NO;
    }
    
    // 启动后台任务
    //    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    for (id obj in response.updateInfo.details) {
        ServerResponseUpdateInfoDetail *detail = (ServerResponseUpdateInfoDetail *)obj;
        if (detail == nil) {
            continue;
        }
        
        // 启动下载任务, 将data pack下载至本地
        NSString *dataId = [NSString stringWithFormat:@"%@", [detail valueForKey:@"id"]];
        NSString *title = [NSString stringWithFormat:@"%@", [detail valueForKey:@"id"]];
        NSString *desc = [NSString stringWithFormat:@"desc_dataId_%@", dataId];
        NSString *downloadUrlStr = [NSString stringWithFormat:@"%@", [detail valueForKey:@"download_url"]];
        NSURL *downloadUrl = [NSURL URLWithString:[downloadUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (downloadUrl == nil) {
            continue;
        }
        
        NSString *decryptKey = [NSString stringWithFormat:@"%@", [detail valueForKey:@"data_encrypt_key"]];
        
        // 下载目录
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, title, [DateUtil timestamp]];
        
        // 下载
        [[KnowledgeDownloadManager instance] startDownloadWithTitle:title andDesc:desc andDownloadUrl:downloadUrl andSavePath:savePath andTag:decryptKey];
    }
    
    // 注: 后续操作位于KnowledgeDownloadManagerDelegate的相关方法中. 包括: 3. 解包 4. 拷贝文件, 更新数据库
    //    });
    
    return YES;
}

// check data update, and apply update according to update mode
- (BOOL)startUpdateData {
    // 启动后台任务
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. 获取data的最新版本文件
        NSURL *url = [NSURL URLWithString:[[Config instance].knowledgeDataConfig.dataUrlForVersion stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // 下载目录
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, @"data_version", [DateUtil timestamp]];
        
        BOOL ret = [[KnowledgeDownloadManager instance] directDownloadWithUrl:url andSavePath:savePath];
        if (!ret) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate] failed to download data version file");
            return;
        }
        
        // 2. 解析下载到的数据版本文件
        NSArray *dataVersionInfoArray = [self parseDataVersionInfo:savePath];
        if (dataVersionInfoArray == nil || dataVersionInfoArray.count <= 0) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate] failed to parse data version file");
            return;
        }
        
        // 3. 收集待检查更新的数据信息
        NSArray *updatableDataVersionInfoArray = [self decideUpdatableData:dataVersionInfoArray];
        if (updatableDataVersionInfoArray == nil) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate] failed to decide updatable  data array, return");
            return;
        }
        
        if (updatableDataVersionInfoArray.count <= 0) {
            LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate] successfully, no data to update");
            return;
        }
        
        // 删除data_version文件
        [PathUtil deletePath:savePath];
        
        // 4. 获取数据的更新信息
        // 4.1 构造数据更新请求
        DataUpdateRequestInfo *dataUpdateRequestInfo = [[DataUpdateRequestInfo alloc] init];
        {
            NSMutableArray *dataInfoArray = [[NSMutableArray alloc] init];
            
            for (id obj in updatableDataVersionInfoArray) {
                ServerDataVersionInfo *dataVersionInfo = (ServerDataVersionInfo *)obj;
                if (dataVersionInfo == nil) {
                    continue;
                }
                
                DataInfo *dataInfo = [[DataInfo alloc] init];
                dataInfo.dataId = dataVersionInfo.dataId;
                dataInfo.curVersion = dataVersionInfo.dataCurVersion; // 数据当前版本
                
                [dataInfoArray addObject:dataInfo];
            }
            
            dataUpdateRequestInfo.dataInfo = dataInfoArray;
        }
        
        // 4.2 获取数据的更新信息
        ServerResponseOfKnowledgeData *response = [self getDataUpdateInfo:dataUpdateRequestInfo];
        if (response == nil || response.updateInfo == nil || response.updateInfo.status < 0) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate] failed to get data update info, return");
            return;
        }
        
        if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
            LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate] failed, server returns no no data update info, return");
            return;
        }

        
        // 5. 将数据库中相关数据标为有更新
        {
            for (id obj in response.updateInfo.details) {
                ServerResponseUpdateInfoDetail *detail = (ServerResponseUpdateInfoDetail *)obj;
                if (detail == nil) {
                    continue;
                }
                
                NSString *dataId = [detail valueForKey:@"id"];
                BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_DETECTED andDataStatusDescTo:detail.updateInfo forDataWithDataId:detail.dataId andType:DATA_TYPE_DATA_SOURCE];
                LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
            }
        }
        
        // 6. 根据更新模式, 启动后台下载, 下载完成后, 自动完成更新
        // 注: 后续操作位于KnowledgeDownloadManagerDelegate的相关方法中. 包括: (1) 解包 (2) 拷贝文件, 更新数据库
        if ([Config instance].knowledgeDataConfig.knowledgeDataUpdateMode == DATA_UPDATE_MODE_CHECK_AND_UPDATE) {
            [self startDownloadWithResponse:response];
        }
    });
    
    return YES;
}

// check data update, and auto apply update
- (BOOL)startUpdateData:(NSString *)dataId {
    // 启动后台任务
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. 获取data的最新版本文件
        NSURL *url = [NSURL URLWithString:[[Config instance].knowledgeDataConfig.dataUrlForVersion stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // 下载目录
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, @"data_version", [DateUtil timestamp]];
        
        BOOL ret = [[KnowledgeDownloadManager instance] directDownloadWithUrl:url andSavePath:savePath];
        if (!ret) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate:] failed to download data version file");
            return;
        }
        
        // 2. 解析下载到的数据版本文件
        NSArray *dataVersionInfoArray = [self parseDataVersionInfo:savePath];
        if (dataVersionInfoArray == nil || dataVersionInfoArray.count <= 0) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate:] failed to parse data version file");
            return;
        }
        
        // 3. 收集待检查更新的数据信息
        NSArray *updatableDataVersionInfoArray = [self decideUpdatableData:dataVersionInfoArray];
        if (updatableDataVersionInfoArray == nil) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate:] failed to decide updatable  data array, return");
            return;
        }
        
        if (updatableDataVersionInfoArray.count <= 0) {
            LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate:] successfully, no data to update");
            return;
        }
        
        // 删除data_version文件
        [PathUtil deletePath:savePath];
        
        // 4. 获取数据的更新信息
        // 4.1 构造数据更新请求
        DataUpdateRequestInfo *dataUpdateRequestInfo = [[DataUpdateRequestInfo alloc] init];
        {
            NSMutableArray *dataInfoArray = [[NSMutableArray alloc] init];
            
            for (id obj in updatableDataVersionInfoArray) {
                ServerDataVersionInfo *dataVersionInfo = (ServerDataVersionInfo *)obj;
                if (dataVersionInfo == nil) {
                    continue;
                }
                
                DataInfo *dataInfo = [[DataInfo alloc] init];
                dataInfo.dataId = dataVersionInfo.dataId;
                dataInfo.curVersion = dataVersionInfo.dataCurVersion; // 数据当前版本
                
                [dataInfoArray addObject:dataInfo];
            }
            
            dataUpdateRequestInfo.dataInfo = dataInfoArray;
        }
        
        // 4.2 获取数据的更新信息
        ServerResponseOfKnowledgeData *response = [self getDataUpdateInfo:dataUpdateRequestInfo];
        if (response == nil || response.updateInfo == nil || response.updateInfo.status < 0) {
            LogError(@"[KnowledgeDataManager-startCheckDataUpdate:] failed to get data update info, return");
            return;
        }
        
        if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
            LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate:] failed, server returns no no data update info, return");
            return;
        }
        
        // 5. 将数据库中相关数据标为有更新
        {
            for (id obj in response.updateInfo.details) {
                ServerResponseUpdateInfoDetail *detail = (ServerResponseUpdateInfoDetail *)obj;
                if (detail == nil || [detail.needUpdateApp isEqualToString:@"0"]) {
                    continue;
                }
                
                NSString *dataId = [detail valueForKey:@"id"];
                BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_DETECTED andDataStatusDescTo:detail.updateInfo forDataWithDataId:detail.dataId andType:DATA_TYPE_DATA_SOURCE];
                LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate:] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
            }
        }
        
        // 6. 根据更新模式, 启动后台下载, 下载完成后, 自动完成更新
        // 注: 后续操作位于KnowledgeDownloadManagerDelegate的相关方法中. 包括: (1) 解包 (2) 拷贝文件, 更新数据库
//        if ([Config instance].knowledgeDataConfig.knowledgeDataUpdateMode == DATA_UPDATE_MODE_CHECK_AND_UPDATE) {
            [self startDownloadWithResponse:response];
//        }
    });
    
    return YES;
}

// 解析dataVersion文件
- (NSArray *)parseDataVersionInfo:(NSString *)dataVersionFilePath {
    NSMutableArray *dataVersionInfoArray = [[NSMutableArray alloc] init];
    
    NSError *error = nil;
    NSString *dataVersionFileContents = [NSString stringWithContentsOfFile:dataVersionFilePath encoding:NSUTF8StringEncoding error:&error];
    if (dataVersionFileContents == nil || dataVersionFileContents.length <= 0) {
        LogError(@"[KnowledgeDataManager-parseDataVersionInfo:] failed to read data version file: %@", dataVersionFilePath);
        return nil;
    }
    
    // 分割成行
    NSArray *lines = [dataVersionFileContents componentsSeparatedByString:@"\n"];
    if (lines == nil || lines.count <= 0) {
        return nil;
    }
    
    // 逐行解析
    NSEnumerator *enumerator = [lines objectEnumerator];
    NSString *curLine = nil;
    while ((curLine = [enumerator nextObject]) != nil) {
        if (curLine == nil || curLine.length <= 0) {
            continue;
        }
        
        JSONModelError *jsonModelError = nil;
        ServerDataVersionInfo *dataVersionInfo = [[ServerDataVersionInfo alloc] init];
        dataVersionInfo = [dataVersionInfo initWithString:curLine usingEncoding:NSUTF8StringEncoding error:&jsonModelError];
        if (dataVersionInfo == nil) {
            LogWarn(@"[KnowledgeDataManager-parseDataVersionInfo:] continue after failure of parse json: %@", curLine);
            continue;
        }
        
        [dataVersionInfoArray addObject:dataVersionInfo];
    }
    
    return dataVersionInfoArray;
}

// 确定可更新的数据集合
- (NSArray *)decideUpdatableData:(NSArray *)dataVersionInfoArray {
    if (dataVersionInfoArray == nil || dataVersionInfoArray.count <= 0) {
        return nil;
    }
    
    // 与本地数据版本比较, 确定可更新的数据集合
//    NSString *curAppVersion = [AppUtil getAppVersionStr];
//    if (curAppVersion == nil || curAppVersion.length <= 0) {
//        return nil;
//    }
    
    NSInteger curAppVersionNum = [AppUtil getAppVersionNum];
    if (curAppVersionNum < 0) {
        return nil;
    }
    
    // 收集待检查更新的数据信息
    NSMutableArray *updatableDataVersionInfoArray = [[NSMutableArray alloc] init];
    
    for (id obj in dataVersionInfoArray) {
        ServerDataVersionInfo *dataVersionInfo = (ServerDataVersionInfo *)obj;
        if (dataVersionInfo == nil) {
            continue;
        }
        
        // 版本比较
        // 确定数据的当前版本
        NSString *dataCurVersion = [[KnowledgeMetaManager instance] getKnowledgeDataVersionWithDataId:dataVersionInfo.dataId andDataType:DATA_TYPE_DATA_SOURCE];
        if (dataCurVersion == nil || dataCurVersion.length <= 0) {
            LogWarn(@"[KnowledgeDataManager-startCheckDataUpdate] failed to decide version of data: %@, invalid dataCurVersion, ignore", dataVersionInfo.dataId);
            continue;
        }
        
        // 收集
        BOOL shouldUpdate = YES;
        {
            if (shouldUpdate && (dataCurVersion == nil
                                 || dataCurVersion.length <= 0)) {
                shouldUpdate = NO;
            }
            
            // 比较数据版本
            // 若本地版本号大于等于最新版本号, 则忽略此数据更新
//            dataCurVersion = @"0.0.0.0"; // test only
            if (shouldUpdate
                && [dataCurVersion compare:dataVersionInfo.dataLatestVersion] >= 0) {
                shouldUpdate = NO;
            }
            
            // 比较App版本
            {
                // 不确定当前app版本时, 则忽略此数据更新, 以免app异常
                if (shouldUpdate && (dataCurVersion == nil
                                     || dataCurVersion.length <= 0)) {
                    shouldUpdate = NO;
                }
                
                // 若当前app版本号在指定的版本号范围之外, 则忽略此数据更新
                if (shouldUpdate && (dataVersionInfo.appVersionMin != nil
                                     && dataVersionInfo.appVersionMin.length > 0)) {
                    NSInteger appVersionNumMin = [dataVersionInfo.appVersionMin intValue];
                    if (curAppVersionNum < appVersionNumMin) {
//                    if ([curAppVersion compare:dataVersionInfo.appVersionMin] < 0) {
                        shouldUpdate = NO;
                    }
                }
                
                if (shouldUpdate && (dataVersionInfo.appVersionMax != nil
                                     && dataVersionInfo.appVersionMax.length > 0)) {
                    NSInteger appVersionNumMax = [dataVersionInfo.appVersionMax intValue];
                    if (curAppVersionNum > appVersionNumMax) {
//                    if ([curAppVersion compare:dataVersionInfo.appVersionMax] > 0) {
                        shouldUpdate = NO;
                    }
                }
            }
        }
        
        if (shouldUpdate) {
            dataVersionInfo.dataCurVersion = dataCurVersion;
            [updatableDataVersionInfoArray addObject:dataVersionInfo];
        }
    }

    return updatableDataVersionInfoArray;
}

// 确定与指定数据相关的可更新的数据集合
- (NSArray *)decideUpdatableData:(NSArray *)dataVersionInfoArray forData:(NSString *)dataId {
    NSArray *updatableDataVersionInfoArray = [self decideUpdatableData:dataVersionInfoArray];
    
    if (updatableDataVersionInfoArray == nil || updatableDataVersionInfoArray.count <= 0) {
        return nil;
    }
    
    
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id obj in updatableDataVersionInfoArray) {
        ServerDataVersionInfo *dataVersionInfo = (ServerDataVersionInfo *)obj;
        if (dataVersionInfo == nil || ![dataVersionInfo.dataId isEqual:dataId]) {
            continue;
        }
        
        [retArray addObject:dataVersionInfo];
    }
    
    return retArray;
}

// 获取各data的更新信息(数据的下载地址等)
- (ServerResponseOfKnowledgeData *)getDataUpdateInfo:(DataUpdateRequestInfo *)requestInfo {
    lastError = @"";
    
    UserInfo *curUserInfo = [[UserManager instance] getCurUser];
    if (curUserInfo == nil || curUserInfo.username == nil) {
        // try default user
        curUserInfo = [UserManager getDefaultUser];
        if (curUserInfo == nil || curUserInfo.username == nil) {
            lastError = @"用户信息不完整, 请确认用户已成功登录";
            return nil;
        }
    }
    
    // crypt
    NSString *secretKey = [MD5Util md5ForString:curUserInfo.password];
    NSString *iv = [MD5Util md5ForString:secretKey];
    CryptUtil *cryptUtil = [[CryptUtil alloc] initWithKey:secretKey andIV:iv];
    
    // Url
    NSString *url = [Config instance].knowledgeDataConfig.dataUrlForUpdate;
    
    // headers
    NSString *userAgent = [Config instance].webConfig.userAgent;
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:userAgent forKey:@"user_agent"];
    
    // body params
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    [data setValue:userAgent forKey:@"user_agent"];
    [data setValue:@"2" forKey:@"encrypt_method"]; // 对称加密
    [data setValue:@"3" forKey:@"encrypt_key_type"];
    [data setValue:@"1" forKey:@"app_platform"]; // ios
    {
        NSString *appVersion = [NSString stringWithFormat:@"%ld", (long)[AppUtil getAppVersionNum]];
        [data setValue:appVersion forKey:@"app_version"]; // app version
    }
    [data setValue:curUserInfo.username forKey:@"user_name"];
    
    // device id
    {
        NSString *deviceId = [DeviceUtil getVendorId];
        [data setValue:deviceId forKey:@"device_id"];
    }
    
    // param data
    {
        // 待加密信息
        NSMutableString *jsonOfDataUpdateRequestInfo = [[NSMutableString alloc] init];
        [jsonOfDataUpdateRequestInfo appendString:@"["];
        
        BOOL isFirst = YES;
        for (id obj in requestInfo.dataInfo) {
            DataInfo *dataInfo = (DataInfo *)obj;
            if (dataInfo == nil) {
                continue;
            }
            
            NSString *json = [dataInfo toJSONString];
            if (json == nil || json.length <= 0) {
                continue;
            }
            
            if (isFirst) {
                isFirst = NO;
            }
            else {
                [jsonOfDataUpdateRequestInfo appendString:@","];
            }
            
            [jsonOfDataUpdateRequestInfo appendString:json];
        }
        
        [jsonOfDataUpdateRequestInfo appendString:@"]"];
        
        // 对称加密
        NSString *encryptedContent = [cryptUtil encryptAES128:jsonOfDataUpdateRequestInfo];
        if (encryptedContent == nil || encryptedContent.length <= 0) {
            lastError = @"数据加密失败";
            return nil;
        }
        
        LogDebug(@"[KnowledgeDataManager-getDataUpdateInfo:] encryptedContent: %@", encryptedContent);
        [data setValue:encryptedContent forKey:@"data"];
    }
    
    // 发送web请求, 获取响应
    NSString *serverResponseStr = [WebUtil sendRequestTo:[NSURL URLWithString:url] usingVerb:@"POST" withHeader:headers andData:data];
    if (serverResponseStr == nil || serverResponseStr.length <= 0) {
        lastError = @"网络请求失败";
        return nil;
    }
    
    // 解析响应: json=>obj
    NSError *error = nil;
    ServerResponseOfKnowledgeData *response = [[ServerResponseOfKnowledgeData alloc] initWithString:serverResponseStr error:&error];
    if (response == nil || response.data == nil
        || response.data.length <= 0) {
        lastError = @"服务器响应数据异常";
        return nil;
    }
    
    // 解析加密后的数据字段
    NSString *decryptedContent = nil;
    if (response.encryptMethod == 2) {
        if (response.encryptKeyType == 3) {
            NSString *encryptedData = [response.data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // 对称解密
            decryptedContent = [cryptUtil decryptAES128:encryptedData];
        }
    }
    
    if (decryptedContent == nil || decryptedContent.length <= 0) {
        lastError = @"数据解析失败";
        return nil;
    }
    
    // trim: 去除尾的\0. 否则json解析时会失败.
    decryptedContent = [decryptedContent stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    if (decryptedContent == nil || decryptedContent.length <= 0) {
        lastError = @"服务器返回数据为空";
        return nil;
    }
    
    // 解析updateInfo: json=>obj
    response.updateInfo = [[ServerResponseUpdateInfo alloc] initWithString:decryptedContent error:&error];
    if (response.updateInfo == nil) {
        lastError = @"服务器返回数据解析失败";
        LogError(@"[KnowledgeDataManager-getDataUpdateInfo:] 解析服务器响应数据失败, error: %@", error.localizedDescription);
        return nil;
    }
    
    // 检查服务器返回状态
    if (response.updateInfo.status != 0) {
        lastError = response.updateInfo.message;
        return nil;
    }
    
    return response;
}


#pragma mark - KnowledgeDownloadManagerDelegate methods

// 下载进度
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress {
    LogDebug(@"download item, id %@, title %@, progress: %@", downloadItem.itemId, downloadItem.title, downloadItem.downloadProgress);
    
    // 将下载进度更新到coreData
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_IN_PROGRESS andDataStatusDescTo:[NSString stringWithFormat:@"%lf", progress] forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
    });
}

// 下载成功/失败
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didFinish:(BOOL)success response:(id)response {
    // log
    {
        NSString *info = nil;
        if (success) {
            info = @" successfully";
        }
        else {
            info = [NSString stringWithFormat:@" failed, error: %@", response];
        }
        
        LogInfo(@"download item, id %@, title %@, finished%@", downloadItem.itemId, downloadItem.title, info);
    }
    
    if (!success) {
        return;
    }
    
    // 将下载进度更新到coreData
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_COMPLETED andDataStatusDescTo:@"100" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
    });
    
    // 启动后台任务, 继续下载的后续操作
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processDownloadedDataPack:downloadItem];
    });
}


#pragma mark - search
// decide searchable data ids
- (NSArray *)decideSearchableDataIds {
    NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] getSearchableKnowledgeMetas];
    if (!knowledgeMetas) {
        return nil;
    }
    
    NSMutableArray *dataIds = [[NSMutableArray alloc] init];
    for (id obj in knowledgeMetas) {
        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
        if (!knowledgeMeta) {
            continue;
        }
        
        [dataIds addObject:knowledgeMeta.dataId];
    }
    
    return dataIds;
}

// search data
- (NSArray *)searchData:(NSString *)searchId {
    // 1. 确定所有需要遍历的文件夹
    NSArray *searchableDataIds = [self decideSearchableDataIds];
    if (searchableDataIds == nil || searchableDataIds.count <= 0) {
        return nil;
    }
    
    // 2. 遍历文件夹中的index, 若命中, 则收集其数据
    NSMutableArray *searchedArray = [[NSMutableArray alloc] init];
    
    for (NSString *dataId in searchableDataIds) {
        NSArray *dataArray = [[KnowledgeDataLoader instance] getKnowledgeDataWithDataId:dataId andQueryId:searchId andIndexFilename:nil];
        
        // collect
        if (dataArray == nil || dataArray.count <= 0) {
            continue;
        }
        
        for (NSString *data in dataArray) {
            if (data && data.length > 0) {
                [searchedArray addObject:data];
            }
        }
    }

    // 3. 返回所有数据
    return searchedArray;
}

@end
