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

@interface KnowledgeDataManager() <KnowledgeDownloadManagerDelegate>

// 获取数据的下载信息
- (ServerResponseOfKnowledgeData *)getDataDownloadInfo:(NSString *)dataId;
// 启动下载
- (BOOL)startDownload:(ServerResponseOfKnowledgeData *)response;
// 下载完成后的后续操作, 包括: (1) 复制目录 (2) 注册数据
- (BOOL)processDownloadedDataPack:(KnowledgeDownloadItem *)downloadItem;

// 处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey;

// 添加或更新数据
- (BOOL)addOrReplaceData:(NSString *)metaFilePath;
// 删除数据
- (BOOL)deleteData:(NSString *)metaFilePath;

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
    
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@/%@", knowledgeDataRootPathInDocuments, knowledgeMetaEntity.dataPath, @"data.json"];
        
    // read file line by line
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
    if (fileContents == nil || fileContents.length <= 0) {
        NSLog(@"[KnowledgeDataManager::loadKnowledgeData()] failed, data id: %@, file: %@, error: %@", knowledgeMetaEntity.dataId, fullFilePath, error.localizedDescription);
        return nil;
    }
    
    return fileContents;
}

#pragma mark - download knowledge data
// start downloading
- (BOOL)startDownloadData:(NSString *)dataId {
    // 启动后台任务
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. 获取该data对应的download_url
        ServerResponseOfKnowledgeData *response = [self getDataDownloadInfo:dataId];
        if (response == nil || response.dataInfo == nil || response.dataInfo.downloadUrl == nil || response.dataInfo.downloadUrl.length <= 0) {
            NSLog(@"[KnowledgeDataManager] startDownloadData() failed because of invalid server response, error: %@", self.lastError);
            return;
        }

        // 2. 启动后台下载任务, 将data pack下载至本地
        [self startDownload:response];
        
        // 注: 后续操作位于KnowledgeDownloadManagerDelegate的相关方法中. 包括: 3. 解包 4. 拷贝文件, 更新数据库
    });
    
    return YES;
}

// get download info
- (ServerResponseOfKnowledgeData *)getDataDownloadInfo:(NSString *)dataId {
    lastError = @"";
    
    UserInfo *curUserInfo = [[UserManager instance] getCurUser];
    if (curUserInfo == nil || curUserInfo.username == nil) {
        lastError = @"用户信息不完整, 请确认用户已成功登录";
        return nil;
    }
    
    // crypt
    NSString *secretKey = [MD5Util md5ForString:curUserInfo.password];
    NSString *iv = [MD5Util md5ForString:secretKey];
    CryptUtil *cryptUtil = [[CryptUtil alloc] initWithKey:secretKey andIV:iv];
    
    // Url
    NSString *url = [Config instance].knowledgeDataConfig.dataUrlForDownload;
    
    // headers
    NSString *userAgent = [Config instance].webConfig.userAgent;
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setValue:userAgent forKey:@"user_agent"];
    
    // body params
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    [data setValue:userAgent forKey:@"user_agent"];
    [data setValue:@"2" forKey:@"encrypt_method"]; // 对称加密
    [data setValue:@"3" forKey:@"encrypt_key_type"];
    
    [data setValue:curUserInfo.username forKey:@"user_name"];
    
    // device id
    {
        NSString *deviceId = [DeviceUtil getVendorId];
        [data setValue:deviceId forKey:@"device_id"];
    }
    
    // param data
    {
        // 待加密信息
        DataDownloadRequestInfo *dataDownloadRequestInfo = [[DataDownloadRequestInfo alloc] init];
        dataDownloadRequestInfo.dataId = dataId;
        NSString *jsonOfDataDownloadRequestInfo = [dataDownloadRequestInfo toJSONString];
        
        // 对称加密
        NSString *encryptedContent = [cryptUtil encryptAES128:jsonOfDataDownloadRequestInfo];
        if (encryptedContent == nil || encryptedContent.length <= 0) {
            lastError = @"数据加密失败";
            return nil;
        }
        
        NSLog(@"encryptedContent: %@", encryptedContent);
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
    
    // 解析dataInfo: json=>obj
    response.dataInfo = [[ServerResponseDataInfo alloc] initWithString:decryptedContent error:&error];
    if (response.dataInfo == nil) {
        lastError = @"服务器返回数据解析失败";
        NSLog(@"error: %@", error.localizedDescription);
        return nil;
    }
    
    // 检查服务器返回状态
    if (response.dataInfo.status != 0) {
        lastError = response.dataInfo.message;
        return nil;
    }
    
    return response;
}

- (BOOL)startDownload:(ServerResponseOfKnowledgeData *)response {
    if (response == nil || response.dataInfo == nil || response.dataInfo.dataId == nil || response.dataInfo.dataId.length <= 0 || response.dataInfo.downloadUrl == nil || response.dataInfo.downloadUrl.length <= 0) {
        return NO;
    }
    
    // 启动下载任务, 将data pack下载至本地
    NSString *title = response.dataInfo.dataId;
    NSURL *downloadUrl = [NSURL URLWithString:[response.dataInfo.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // 下载目录
    NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
    NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, title, [DateUtil timestamp]];
    
    // 下载
    return [[KnowledgeDownloadManager instance] startDownloadWithTitle:title andDesc:[NSString stringWithFormat:@"desc_dataId_%@", response.dataInfo.dataId] andDownloadUrl:downloadUrl andSavePath:savePath andTag:response.dataInfo.decryptKey];
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
        
        NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() started, file: %@", downloadItem.savePath);
        
        // 1. 解包
        NSString *unpackPath = [NSString stringWithFormat:@"%@-unpack", downloadItem.savePath];
        {
            // 1.1 unzip
            ZipArchive *za = [[ZipArchive alloc] init];
            // 此处解包不需要密码
            //        ret = [za unzipOpenFile:downloadItem.savePath password:downloadItem.tag];
            ret = [za unzipOpenFile:downloadItem.savePath];
            if (!ret) {
                NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, since failed to open zip file: %@", downloadItem.savePath);
                ret = NO;
                break;
            }
            
            ret = [za unzipFileTo:unpackPath overwrite:YES];
            if (!ret) {
                NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, since failed to unzip zip file: %@", downloadItem.savePath);
                ret = NO;
                break;
            }
            
            // 1.2 check whether unzip path exists
            BOOL isDir = NO;
            BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackPath isDirectory:&isDir];
            if (!existed) {
                NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, since there is no unzip file after unzip. The zip file is: %@", downloadItem.savePath);
                ret = NO;
                break;
            }
            
            // 1.3 check md5, and collect zipped data files
            {
                NSError *error = nil;
                NSString *md5File = [NSString stringWithFormat:@"%@/%@", unpackPath, @"md5.txt"];
                NSString *md5FileContents = [NSString stringWithContentsOfFile:md5File encoding:NSUTF8StringEncoding error:&error];
                if (md5FileContents == nil || md5FileContents.length <= 0) {
                    NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, invalid md5 file. The zip file is: %@", downloadItem.savePath);
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
                        NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, sice md5 check failed. The failed file is: %@", filename);
                        ret = NO;
                        break;
                    }
                    
                    [zippedDataFiles addObject:filename];
                }
            }
        }
        
        if (zippedDataFiles == nil || zippedDataFiles.count <= 0) {
            NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, since no zipped data files. The zip file is: %@", downloadItem.savePath);
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
                    NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() failed, since failed to process zipped data file: %@", zippedDataFilename);
                    ret = NO;
                    break;
                }
            }
        }
    } while (NO);
    
    // 3. 删除已下载的数据文件
    [PathUtil deletePath:downloadItem.savePath];
    NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() deleted downloaded data file: %@", downloadItem.savePath);
    
    // 3. 返回
    NSLog(@"[KnowledgeDataManager] processDownloadedDataPack() end %@, file: %@", (ret ? @"successfully" : @"failed"), downloadItem.savePath);
    return ret;
}

// 处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey {
    BOOL ret = YES;
    
    NSString *unpackPath = [filename stringByDeletingLastPathComponent];
    NSString *unpackedDataPath = [filename stringByDeletingPathExtension];
    
    NSLog(@"[KnowledgeDataManager] processZippedDataFile() started, file: %@", filename);
    do {
        // 1. 解包
        {
            // 1.1 unzip
            ZipArchive *za = [[ZipArchive alloc] init];
            BOOL ret = [za unzipOpenFile:filename password:decryptedKey];
            if (!ret) {
                NSLog(@"[KnowledgeDataManager] processZippedDataFile() failed, since failed to open zip file: %@", filename);
                ret = NO;
                break;
            }
            
            ret = [za unzipFileTo:unpackPath overwrite:YES];
            if (!ret) {
                NSLog(@"[KnowledgeDataManager] processZippedDataFile() failed, since failed to unzip zip file: %@", filename);
                ret = NO;
                return NO;
            }
            
            // 1.2 check whether unzip path exists
            BOOL isDir = NO;
            BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackedDataPath isDirectory:&isDir];
            if (!existed) {
                NSLog(@"[KnowledgeDataManager] processZippedDataFile() failed, since there is no unzip file after unzip. The zip file is: %@", filename);
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
                NSLog(@"[KnowledgeDataManager] processZippedDataFile() failed, invalid operation file: %@", fullOperationFilename);
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
    NSLog(@"[KnowledgeDataManager] processZippedDataFile() deleted unpacked data path: %@", unpackPath);
    
    // 3. 返回
    NSLog(@"[KnowledgeDataManager] processZippedDataFile() end %@, file: %@", (ret ? @"successfully" : @"failed"), filename);
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
                knowledgeMeta.DataStatus = DATA_STATUS_UPDATED;
                knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
                
                knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
                knowledgeMeta.updateTime = [NSDate date];
                
                ret = [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
            }
        }
        // replace
        else {
            // 1. 将数据状态修改为updating
            ret = [[KnowledgeMetaManager instance] setData:knowledgeMeta.dataId toStatus:DATA_STATUS_UPDATING];
            
            // 2. 替换文件夹
            NSString *fromPath = [metaFilePath stringByDeletingLastPathComponent];
            NSString *toPath = [NSString stringWithFormat:@"%@/%@", [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments, knowledgeMeta.dataPath ];
            
            ret = [PathUtil copyFilesFromPath:fromPath toPath:toPath];
            
            // 3. 修改数据状态及其它相关属性
            if (ret) {
                knowledgeMeta.DataStorageType = DATA_STORAGE_INTERNAL_STORAGE;
                knowledgeMeta.DataStatus = DATA_STATUS_UPDATED;
                knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
                
                knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
                knowledgeMeta.updateTime = [NSDate date];
                
                ret = [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
            }
            else {
                ret = [[KnowledgeMetaManager instance] setData:knowledgeMeta.dataId toStatus:DATA_STATUS_AVAIL];
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


#pragma mark - KnowledgeDownloadManagerDelegate methods

// 下载进度
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress {
    NSLog(@"download item, id %@, title %@, progress: %@", downloadItem.itemId, downloadItem.title, downloadItem.downloadProgress);
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
        
        NSLog(@"download item, id %@, title %@, finished%@", downloadItem.itemId, downloadItem.title, info);
    }
    
    if (!success) {
        return;
    }
    
    // 启动后台任务, 继续下载的后续操作
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processDownloadedDataPack:downloadItem];
    });
}


@end
