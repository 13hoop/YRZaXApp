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
@property (nonatomic, strong) NSString *globalSavePath;
@property (nonatomic, assign) BOOL originalBookHavedExist;


#pragma mark - 数据下载
// 根据ServerResponseOfKnowledgeData, 启动下载更新
- (BOOL)startDownloadWithResponse:(ServerResponseOfKnowledgeData *)response;

// 下载完成后的后续操作, 包括: (1) 复制目录 (2) 注册数据
- (BOOL)processDownloadedDataPack:(KnowledgeDownloadItem *)downloadItem;

// 处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey;
//2.0处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey withDownloadItemTitle:(NSString *)downloadTitle;

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
//- (ServerResponseOfKnowledgeData *)getDataUpdateInfo:(DataUpdateRequestInfo *)requestInfo;
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
            // 分别尝试无密码和有密码两种unzip方式. 因: 第一次解zip包不需要使用密码, 而第二次解zip包需要使用密码.
            NSMutableArray *passwords = [[NSMutableArray alloc] init];
            [passwords addObject:@""];
            if (downloadItem.tag != nil && downloadItem.tag.length > 0) {
                [passwords addObject:downloadItem.tag];
            }
            
            ZipArchive *za = [[ZipArchive alloc] init];
            
            for (NSString *password in passwords) {
    
                //2.0中将 准备解包  的状态存到数据库
//                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UNPACK_PREPARING andDataStatusDescTo:@"92" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
//                });

                
                if (password == nil || password.length <= 0) {
                    ret = [za unzipOpenFile:downloadItem.savePath];
                }
                else {
                    ret = [za unzipOpenFile:downloadItem.savePath password:downloadItem.tag];
                }
                
                ret = [za unzipFileTo:unpackPath overwrite:YES];
                //2.0 解包中
//                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UNPACK_IN_PROGRESS andDataStatusDescTo:@"94" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
//                });
                if (!ret) {
                    LogError(@"[KnowledgeDataManager:processDownloadedDataPack:] failed, since failed to unzip zip file: %@", downloadItem.savePath);
                    ret = NO;
                    continue; // 继续尝试下一password
                }
                
                // 1.2 check whether unzip path exists
                BOOL isDir = NO;
                //H:判断指定的文件是否存在
                BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackPath isDirectory:&isDir];
                if (existed) {
                    //2.0 在这里将进度+5
//                    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UNPACK_IN_PROGRESS andDataStatusDescTo:@"95" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
//                    });
                    
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
                    //H:文件，字符串分隔的判断是很有必要的，因为会有@“”出现。也就是说用空格分割后会出现空字段。
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
                
//                ret = [self processZippedDataFile:zippedDataFilename withDecryptKey:downloadItem.tag];
                ret = [self processZippedDataFile:zippedDataFilename withDecryptKey:downloadItem.tag withDownloadItemTitle:downloadItem.title];
                
                if (!ret) {
                    LogError(@"[KnowledgeDataManager-processDownloadedDataPack:] since failed to process zipped data file: %@", zippedDataFilename);
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
    
    //4.处理试读书
    //(1)删除数据库中试读书的信息 (2)判断试读书文件是否存在，若存在，则删除
    //不是所有的试读书都要删，只有在下载了整书后才需要删除试读书
    NSString *needDeleteBookId = [NSString stringWithFormat:@"%@-partial",downloadItem.title];
    
    //删除数据库中的记录
    /*
    NSArray *bookKnowLedgeArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:needDeleteBookId];
    if (bookKnowLedgeArray == nil || bookKnowLedgeArray.count <= 0) {//没有需要删除的试读数据
        LogInfo (@"[KnowledgeDataManager - processDownloadedDataPack:] no partial data need to delete");
        return ret;
    }
    BOOL deletePartialSuccess = [[KnowledgeMetaManager instance] deleteKnowledgeMetaWithDataId:needDeleteBookId];
    if (!deletePartialSuccess) {
        LogError(@"[KnowledgeDataManager - processDownloadedDataPack:] delete partial data from db failed ");
    }
    */
    //删除对应的试读书文件（删除不必要的文件，节省系统空间）
    NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    NSString *needDeletePartialPath = [NSString stringWithFormat:@"%@/%@",knowledgeDataInDocument,needDeleteBookId];
    BOOL needDeleteBookExist = [[NSFileManager defaultManager] fileExistsAtPath:needDeletePartialPath];
    if (!needDeleteBookExist) {//需要删除的数据文件不存在,不需要做处理，直接返回
        return ret;
    }
    NSError *deletePartialError;
    BOOL deletePartialBookFileSuccess = [[NSFileManager defaultManager] removeItemAtPath:needDeletePartialPath error:&deletePartialError];
    if (!deletePartialBookFileSuccess) {//删除本地文件失败，提示
        LogError(@"[KnowledgeDataManager - processDownloadedDataPack]: delete partial book file failed with errorInfo %@",deletePartialError.localizedDescription);
    }
    
    
    return ret;
}


//H:同下面方法的却别，加了一个参数downloadTitle，其余内容完全一致(现用到了这个方法进行二次解包)
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey withDownloadItemTitle:(NSString *)downloadTitle {
    BOOL ret = YES;
    //unpackPath:未打包文件的路径
    NSString *unpackPath = [filename stringByDeletingLastPathComponent];
    //2.0中第二次解压得到的目录名称是book_id
    NSString *unpackedDataPath = [NSString stringWithFormat:@"%@/%@",unpackPath,downloadTitle];
    
    LogInfo(@"[KnowledgeDataManager-processZippedDataFile:] started, file: %@", filename);
    do {
        // 1. 解包
        {
            // 1.1 unzip
            ZipArchive *za = [[ZipArchive alloc] init];
            //H：解包时密码输入错误也是可以解出相应的目录的，只是每个目录下都是0字节的文件。
            //正确写法：
            BOOL ret = [za unzipOpenFile:filename password:decryptedKey];
            //测试写法：
//            BOOL ret = [za unzipOpenFile:filename password:@"123"];
            
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
            //2.0解析出来的数据结构变了，不在是解压包的名字，而直接是data_id,判断是否解包成功.
             //1.2 check whether unzip path exists
                        BOOL isDir = NO;
                        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackedDataPath isDirectory:&isDir];
                        if (!existed) {
                            LogError(@"[KnowledgeDataManager-processZippedDataFile:] failed, since there is no unzip file after unzip. The zip file is: %@", filename);
                            ret = NO;
                            break;
                        }
            
            
            //******** unpackDataPath 是直接到具体书名的path ****
            // 2.0 做解压失败的判断
            BOOL unpackSuccess = [self checkResultWithFilePath:unpackedDataPath];
            if (!unpackSuccess) {
                //1 解包出现错误归类为下载失败，2 数据版本号不修改
//                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_FAILED andDataStatusDescTo:@"0" forDataWithDataId:downloadTitle andType:DATA_TYPE_DATA_SOURCE];
                //2 删除第一次解包得到的文件
                [PathUtil deletePath:unpackPath];
//                });
                return NO;//解包出现错误，在这里直接跳出该方法体。
            }
            
            
            //2.0 解包成功（解包完成）
//            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UNPACK_COMPLETED andDataStatusDescTo:@"100" forDataWithDataId:downloadTitle andType:DATA_TYPE_DATA_SOURCE];
//            });
        }
        
        //2.0修改：做判断，若是存在op.lst文件则按照1.0中的逻辑走，否则按照2.0设计逻辑走
        NSString *operationFilename = @"op.lst";
        NSString *fullOperationFilename = [NSString stringWithFormat:@"%@/%@", unpackedDataPath, operationFilename];
        BOOL opListIsExit = [[NSFileManager defaultManager] fileExistsAtPath:fullOperationFilename];
        if (!opListIsExit) {
            //不存在，执行2.0逻辑
            NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
            NSString *toPath = [NSString stringWithFormat:@"%@/%@",knowledgeDataInDocument,downloadTitle];
            //data_id
            BOOL isDir = NO;
            BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:knowledgeDataInDocument isDirectory:&isDir];
            if (!isExit) {
                [[NSFileManager defaultManager] createDirectoryAtPath:knowledgeDataInDocument withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //
            BOOL ret = [PathUtil copyFilesFromPath:unpackedDataPath toPath:toPath];
            if (!ret) {
                LogError(@"knowledgeDataManager -- processZippedDataFile:withDecryprtKey : copy file form path to purpose failed,please check");
            }
            //后续需要写读文件内容，存到数据库中的操作。，存到数据库中的操作。存book的相对路径，修改book的版本号，修改dataStatus。（在调用该方法的函数内写）
            
            //1 dataStatusDesc置为100 2 状态为更新完成时才会将数据库中latestVersion字段赋值给cruVersion字段 。若是出现捷报错误，这段代码不会被执行。
//            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[KnowledgeMetaManager instance]setDataStatusTo:DATA_STATUS_UPDATE_COMPLETED andDataStatusDescTo:@"100" andDataLatestVersion:nil andDataPath:downloadTitle andDataStorageType:DATA_STORAGE_INTERNAL_STORAGE forDataWithDataId:downloadTitle andType:DATA_TYPE_DATA_SOURCE];
//            });
            
            
        }
        else {
            // 2. 根据op.lst, 进行相应的操作
            //        NSString *operationFilename = @"op.lst";
            NSString *dataDirname = @"node";
            //问题：op.lst文件的内容为0字节？导致解析出错，出错原因：密码错误时可以解析但是解析出来的结果是0字节
            //        NSString *fullOperationFilename = [NSString stringWithFormat:@"%@/%@", unpackedDataPath, operationFilename];
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
                
                // 逐行解析 operation文件的作用有两个 H:找到的是meta.json文件的路径
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
                    //H:判断meta文件是否存在
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
        }
        
    } while (NO);
    
    // 2. 删除unpacked文件夹
    [PathUtil deletePath:unpackPath];
    LogInfo(@"[KnowledgeDataManager] processZippedDataFile() deleted unpacked data path: %@", unpackPath);
    
    // 3. 返回
    LogInfo(@"[KnowledgeDataManager] processZippedDataFile() end %@, file: %@", (ret ? @"successfully" : @"failed"), filename);
    return ret;
}


//H：第二次解包
// 处理已打包的data file
- (BOOL)processZippedDataFile:(NSString *)filename withDecryptKey:(NSString *)decryptedKey {
    BOOL ret = YES;
    //unpackPath:未打包文件的路径
    NSString *unpackPath = [filename stringByDeletingLastPathComponent];
    //2.0中第二次解压得到的目录名称是book_id
    NSString *unpackedDataPath = [filename stringByDeletingPathExtension];
    
    LogInfo(@"[KnowledgeDataManager-processZippedDataFile:] started, file: %@", filename);
    do {
        // 1. 解包
        {
            // 1.1 unzip
            ZipArchive *za = [[ZipArchive alloc] init];
            //H：解包时密码输入错误也是可以解出相应的目录的，只是每个目录下都是0字节的文件。
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
            

            //2.0解析出来的数据结构变了，不在是解压包的名字，而直接是data_id,所以下面的判断不起作用了
            //判断是否解包成功
            // 1.2 check whether unzip path exists
//            BOOL isDir = NO;
//            BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:unpackedDataPath isDirectory:&isDir];
//            if (!existed) {
//                LogError(@"[KnowledgeDataManager-processZippedDataFile:] failed, since there is no unzip file after unzip. The zip file is: %@", filename);
//                ret = NO;
//                break;
//            }
        }
        
        //2.0修改：做判断，若是存在op.lst文件则按照1.0中的逻辑走，否则按照2.0设计逻辑走
        NSString *operationFilename = @"op.lst";
        NSString *fullOperationFilename = [NSString stringWithFormat:@"%@/%@", unpackedDataPath, operationFilename];
        BOOL opListIsExit = [[NSFileManager defaultManager] fileExistsAtPath:fullOperationFilename];
        if (!opListIsExit) {
            //不存在，执行2.0逻辑
            NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
            //data_id
            BOOL isDir = NO;
            BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:knowledgeDataInDocument isDirectory:&isDir];
            if (!isExit) {
                [[NSFileManager defaultManager] createDirectoryAtPath:knowledgeDataInDocument withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //
             BOOL ret = [PathUtil copyFilesFromPath:unpackPath toPath:knowledgeDataInDocument];
            if (!ret) {
                LogError(@"knowledgeDataManager -- processZippedDataFile:withDecryprtKey : copy file form path to purpose failed,please check");
            }
            //后续需要写读文件内容，存到数据库中的操作。存book的相对路径，修改book的版本号，修改dataStatus
            
            
            
            
        }
        else {
            // 2. 根据op.lst, 进行相应的操作
            //        NSString *operationFilename = @"op.lst";
            NSString *dataDirname = @"node";
            //问题：op.lst文件的内容为0字节？导致解析出错，出错原因：密码错误时可以解析但是解析出来的结果是0字节
            //        NSString *fullOperationFilename = [NSString stringWithFormat:@"%@/%@", unpackedDataPath, operationFilename];
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
                
                // 逐行解析 operation文件的作用有两个 H:找到的是meta.json文件的路径
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
                    //H:判断meta文件是否存在
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
            //若是不存在，则按照新下载的meta.json中路径信息来创建一个新的路径。
            /*为了支持能够分别读取bundle和sandBox中的文件，修改说明：
             1、toPath是根据zip包中的meta.json中储存的信息path来存的。若meta文件中记录的信息本地没有：只需要将meta信息添加进数据库中，读取时通过判断DataStorageType字段，确定到sandBox中找html页面、index文件、shit等文件内容。
             2、所以在新add的情况下：toPath指定的路径可以找到sandBox中对应的文件。
             3、shit文件要更新，存到沙盒目录下。
             */
            NSLog(@"这是下载的内容要最终存储的路径===%@",toPath);
            
            ret = [PathUtil copyFilesFromPath:fromPath toPath:toPath];

            // 2. 修改数据状态及其它相关属性
            if (ret) {
                knowledgeMeta.DataStorageType = DATA_STORAGE_INTERNAL_STORAGE;
                knowledgeMeta.DataStatus = DATA_STATUS_UPDATE_COMPLETED;
                knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
                
                knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
                knowledgeMeta.updateTime = [NSDate date];
                //保存到数据库中
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
            NSLog(@"这是下载的内容要最终存储的路径===%@",toPath);
            /*
             replace:为了支持能够分别读取bundle和sandBox中的文件，修改说明：
             
             1、查db后发现本地已有数据文件存在，而且是在bundle中：
                operation：（1）将新下载的文件拷贝到sanbox中，copyFilesFromPath： toPath：将新文件拷到空白目录下。
                     （2）修改db中DataStorageType，再次读取该部分的内容是，通过判断，加载显示sandBox下的内容。
             2、查db后发现本地已有数据文件存在，而且是在sandBox中：
                operation:（1）新老目录下的文件对比，存在相同的文件，则用新的替换旧文件
                            （2）修改db中的DataStorageType
             3、1、2的操作都需要替换掉shit文件所在的整个目录。
             */
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
#pragma mark delete data according to DataStorageType
//H: 删除数据
- (BOOL)deleteDataAccordingToDataStorageType:(NSString *)metaFilePath {
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
        if (originalKnowledgeMetas == nil || originalKnowledgeMetas.count <= 0) {
            
            LogWarn (@"[knowledgeDataManager-deleteDataAccordingToDataStorageType] delete original data failed because of no knowledgeMeta found from db");
            
        }
        // 1. 将meta信息从coreData中删除
        ret = [[KnowledgeMetaManager instance] deleteKnowledgeMetaWithDataId:knowledgeMeta.dataId andDataType:DATA_TYPE_DATA_SOURCE];
    
        // 2. 将data文件删除  H:这样删除只能删除sandBox下的内容，若是找不到路径，也不会出问题，已做判断。
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
        LogError(@"[KnowledgeDataManager-startDownloadWithResponse:] failed because of invalid server response");
        return NO;
    }
    
    if (response.updateInfo.status != 0) {
        LogError(@"[KnowledgeDataManager-startDownloadWithResponse:] failed because of invalid server response, status: %ld, message: %@", response.updateInfo.status, response.updateInfo.message);
        return NO;
    }
    
    if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
        LogError(@"[KnowledgeDataManager-startDownloadWithResponse:] failed because of invalid server response, no details");
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
        NSString *dataId = [NSString stringWithFormat:@"%@", [detail valueForKey:@"data_id"]];
        NSString *title = [NSString stringWithFormat:@"%@", [detail valueForKey:@"data_id"]];
        NSString *desc = [NSString stringWithFormat:@"desc_dataId_%@", dataId];
        //正确写法：
        NSString *downloadUrlStr = [NSString stringWithFormat:@"%@", [detail valueForKey:@"download_url"]];
//        NSURL *downloadUrl = [[NSURL alloc] initWithString:downloadUrlStr];
        NSURL *downloadUrl = [NSURL URLWithString:[downloadUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        
    
        /*
        //测试写法：
        NSString *haoyutestURL = @"http://test.zaxue100.com//1^ios_00101015^1.0.0.1.zip";
        NSURL *downloadUrl = [NSURL URLWithString:[haoyutestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
         */
        
        
        if (downloadUrl == nil || downloadUrlStr.length <= 0) {
            LogWarn(@"[KnowLedgeDataManager - startDownloadWithResponse] downlaodUrl is nil");
            //解决下载失败后native同页面处理不同步的问题
            if (dataId != nil && dataId.length > 0) {
                //1 根据bookId获取对应数据的状态是否为可更新
                NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
                for (id objc in bookArr) {
//                    KnowledgeMeta *bookMeta = (KnowledgeMeta *)objc;
                    KnowledgeMeta *bookMeta = [KnowledgeMeta fromKnowledgeMetaEntity:objc];

                    if (bookMeta == nil) {
                        continue;
                    }
                    //dataId是主键，只能查找到唯一一个元素
                    //2 判断是否为可更新,若是则不做修改,反之修改数据库
                    if (bookMeta.dataStatus != DATA_STATUS_UPDATE_DETECTED) {
                        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_FAILED andDataStatusDescTo:@"0" forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                    }
                }
                
            }
            
            
            continue;
        }
        
        
        
        // *********** 存一个全局的变量，用于区分下载类型：普通下载、更新性质的下载 ***********
        NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
        NSString *originalBookPath = [NSString stringWithFormat:@"%@/%@",knowledgeDataInDocument,dataId];
        BOOL originalBookExist = [[NSFileManager defaultManager] fileExistsAtPath:originalBookPath];
        self.originalBookHavedExist = originalBookExist;//判断是否为更新操作。有书籍存在，则判定为更新操作
        
        
        
        
        
        
        NSString *decryptKey = [NSString stringWithFormat:@"%@", [detail valueForKey:@"data_encrypt_key"]];
        
        // 下载目录
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, title, [DateUtil timestamp]];
        //将savePath存成全局的属性
        self.globalSavePath = savePath;
        
        
        
        LogInfo(@"下载目录是======%@",savePath);//在这里判断文件是否存，若存在则删除
        
        // 下载
        [KnowledgeDownloadManager instance].delegate = self;
        //
        [[KnowledgeDownloadManager instance] startDownloadWithTitle:title andDesc:desc andDownloadUrl:downloadUrl andSavePath:savePath andTag:decryptKey];
    }
    
    // 注: 后续操作位于KnowledgeDownloadManagerDelegate的相关方法中. 包括: 3. 解包 4. 拷贝文件, 更新数据库
    //    });
    
    return YES;
}
// H:
- (void)startDownloadWithUrl:(NSURL *)downloadUrl andTitle:(NSString *)title andDesc:(NSString *)desc andWithTag:(NSString *)tag andSavePath:(NSString *)path {
    [KnowledgeDownloadManager instance].delegate = self;
    [[KnowledgeDownloadManager instance] startDownloadWithTitle:title andDesc:desc andDownloadUrl:downloadUrl andSavePath:path andTag:tag];
}


//2.0先注释掉

// check data update, and apply update according to update mode
- (BOOL)startUpdateData {

    // 启动后台任务
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. 获取data的最新版本文件
        NSURL *url = [NSURL URLWithString:[[Config instance].knowledgeDataConfig.dataUrlForVersion stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // 下载目录
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, @"data_version", [DateUtil timestamp]];
        //
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
        
        // 删除data_version文件 ---- 没有数据更新时也应该删去刚下载的版本文件,前面的return跳出了执行，导致没有执行没下面这句。
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
            
            dataUpdateRequestInfo.dataInfo = dataInfoArray;//现在要根据获取到的数据进行一个post请求。才能获取到下载url的链接
        }
        
        // 4.2 获取数据的更新信息  getDataUpdateInfo：是一个post请求
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
        //更新模式：（1）检查更新并将更新添加到数据库中（2）检查更新并将完成更新
        if ([Config instance].knowledgeDataConfig.knowledgeDataUpdateMode == DATA_UPDATE_MODE_CHECK_AND_UPDATE) {
            [self startDownloadWithResponse:response];
        }
    });
    
    return YES;
}
 
#pragma mark start download new book
//2.0先注释掉 H:
- (BOOL)startDownloadDataWithDataId:(NSString *)dataId {
    //（1）js传一个dataId到 native ，native根据dataId从数据库中取出对应dataId的当前版本号
    NSString *dataCurVersion = nil;
    //限定dataType
    
    dataCurVersion = [[KnowledgeMetaManager instance] getKnowledgeDataVersionWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
    
//    dataCurVersion = [[KnowledgeMetaManager instance] getKnowledgeDataVersionWithDataId:dataId];
    
    if (dataCurVersion == nil || dataCurVersion.length <=0) {//下载一本新书
        LogDebug(@"Debug | [KnowLedgeDataManager-startDownloadDataWithDataId] : get current version info failed because of no data found");
        //        return NO;
        dataCurVersion = @"0.0.0.0";
    }
    
    DataUpdateRequestInfo *dataUpdateRequestInfo = [[DataUpdateRequestInfo alloc] init];
    {
        NSMutableArray *dataInfoArray = [[NSMutableArray alloc] init];
        DataInfo *dataInfo = [[DataInfo alloc] init];
        dataInfo.dataId = dataId;
        dataInfo.curVersion = dataCurVersion; // 数据当前版本
        [dataInfoArray addObject:dataInfo];
        dataUpdateRequestInfo.dataInfo = dataInfoArray;//现在要根据获取到的数据进行一个post请求。才能获取到下载url的链接
    }
    //（2）
    
    //  获取数据的更新信息  getDataUpdateInfo：是一个post请求
    ServerResponseOfKnowledgeData *response = [self getDataUpdateInfo:dataUpdateRequestInfo];
    if (response == nil || response.updateInfo == nil || response.updateInfo.status < 0) {
        LogError(@"[KnowledgeDataManager-startDownloadDataWithDataId] failed to get data update info, return");
        
        
        
        
        // ******* 没网时服务器响应是空的，这时需要将下载状态改为下载失败 ******
        
        //解决下载失败后native同页面处理不同步的问题
        if (dataId != nil && dataId.length > 0) {
            //1 根据bookId获取对应数据的状态是否为可更新
            NSArray *bookArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
            for (id objc in bookArr) {
//                KnowledgeMeta *bookMeta = (KnowledgeMeta *)objc;
                KnowledgeMeta *bookMeta = [KnowledgeMeta fromKnowledgeMetaEntity:objc];

                if (bookMeta == nil) {
                    continue;
                }
                //dataId是主键，只能查找到唯一一个元素
                //更新下载时，进行到这一步数据的状态是不会发生变化的（仍然为可更新）。
                //2 判断是否为可更新,若是则不做修改,反之修改数据库
                if (bookMeta.dataStatus != DATA_STATUS_UPDATE_DETECTED) {
                    [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_FAILED andDataStatusDescTo:@"0" forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                }
            }
            
        }
        
        
        
        
        return NO;
    }
    
    if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
        LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate] H:update failed because no update info return from server ");
        return NO;
    }
   
    
    
    // (4)H：根据服务器返回信息进行下载，下面两种方式都可以：
    //方法1：
        [self startDownloadWithResponse:response];
    /*
    //方法2：
    for (id tempObj in response.updateInfo.details) {
        ServerResponseUpdateInfoDetail *detail = (ServerResponseUpdateInfoDetail *)tempObj;
        if (detail == nil) {
            continue;
        }
        
        NSString *downLoadUrlStr = [[detail valueForKey:@"download_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *downLoadUrl = [NSURL URLWithString:downLoadUrlStr];
        if (downLoadUrlStr == nil || downLoadUrlStr.length <=0 ) {
            LogError (@"ERROR | [knowledgeDataManager-checkUpdateWithDataId ] get download url failed because of download url not found");
            //(1)downloadUrl非空说明为需要下载。通过判断这个字段是否为空来确定是否需要进行更新。
            NSString *downloadUrl = [detail valueForKey:@"download_url"];
            //(2)设置一个代理，当没有更新信息时触发代理来提醒用户当前是最新版本信息
            [self.dataStatusDelegate isShouldUpdateWithUpdateMessage:downloadUrl];
            return NO;
        }
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, [detail valueForKey:@"id"], [DateUtil timestamp]];
        //H:这里一定不要误会title，title的值是id。
        [self startDownloadWithUrl:downLoadUrl andTitle:[detail valueForKey:@"id"] andDesc:[detail valueForKey:@"update_info"] andWithTag:[detail valueForKey:@"data_encrypt_key"] andSavePath:savePath];
    }
    
    */
    
    return YES;

}


#pragma mark get update info file from server
//H:通过从服务器获取到的更新文件信息，并同本地的数据版本进行对比，收集需要更新的数据
//进行所有书籍的更新检测操作，有更新模式来决定是否自动更新
- (BOOL)getUpdateInfoFileFromServerAndUpdateDataBase {
    // 启动后台任务
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 1. 获取data的最新版本文件
        NSURL *url = [NSURL URLWithString:[[Config instance].knowledgeDataConfig.dataUrlForVersion stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // 下载目录
        NSString *downloadRootPath = [Config instance].knowledgeDataConfig.knowledgeDataDownloadRootPathInDocuments;
        NSString *savePath = [NSString stringWithFormat:@"%@/%@-%@", downloadRootPath, @"data_version", [DateUtil timestamp]];
        //
        BOOL ret = [[KnowledgeDownloadManager instance] directDownloadWithUrl:url andSavePath:savePath];
        if (!ret) {
            LogError(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] failed to download data version file");
            return;
        }
        
        // 2. 解析下载到的数据版本文件
        NSArray *dataVersionInfoArray = [self parseDataVersionInfo:savePath];
        if (dataVersionInfoArray == nil || dataVersionInfoArray.count <= 0) {
            LogError(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] failed to parse data version file");
            return;
        }
        
        // 3. 收集待检查更新的数据信息--
        NSArray *updatableDataVersionInfoArray = [self decideUpdatableData:dataVersionInfoArray];
        if (updatableDataVersionInfoArray == nil) {
            LogError(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] failed to decide updatable  data array because of updatableDataVersionInfoArray is eaual nil");
            return;
        }
        //没有信息需要更新 --需要把updatableDataVersionInfoArray返回给js
        if (updatableDataVersionInfoArray.count <= 0) {
            LogInfo(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] successfully, no data to update");
            //4.代理调用
            NSString *updateInfo = @"successfully no data to update";
            [self.dataStatusDelegate returnPromptInformationToJSWithInformation:updateInfo];
            //4.2 H:没有需要更新的信息时，将版本信息文件删除。
            [PathUtil deletePath:savePath];
            return;
        }
        //4.3 H:将收集到的需要更新的信息通过代理来传值，数组中存的是ServerDataVersionInfo对象。可以获取到版本号等信息。
        [self.dataStatusDelegate returnUpdatableDataVersionInfo:updatableDataVersionInfoArray];
        //5.删除版本文件
         [PathUtil deletePath:savePath];
        //6.下面的操作是构造更新请求并将更新信息存到数据库中
        //
        // 6.1 构造数据更新请求
        DataUpdateRequestInfo *dataUpdateRequestInfo = [[DataUpdateRequestInfo alloc] init];
        {
            NSMutableArray *dataInfoArray = [[NSMutableArray alloc] init];
            
            for (id obj in updatableDataVersionInfoArray) {
                ServerDataVersionInfo *dataVersionInfo = (ServerDataVersionInfo *)obj;
                if (dataVersionInfo == nil) {
                    continue;
                }
                //只需要updatableDataVersionInfoArray中对象的两个字段：id字段和当前版本字段
                DataInfo *dataInfo = [[DataInfo alloc] init];
                dataInfo.dataId = dataVersionInfo.dataId;
                dataInfo.curVersion = dataVersionInfo.dataCurVersion; // 数据当前版本
                
                [dataInfoArray addObject:dataInfo];
            }
            
            dataUpdateRequestInfo.dataInfo = dataInfoArray;//现在要根据获取到的数据进行一个post请求。才能获取到下载url的链接
        }
        
        // 6.2 获取数据的更新信息  getDataUpdateInfo：是一个post请求(response已经按照新的参数格式处理)。
        ServerResponseOfKnowledgeData *response = [self getDataUpdateInfo:dataUpdateRequestInfo];
        if (response == nil || response.updateInfo == nil || response.updateInfo.status < 0) {
            LogError(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] failed to get data update info, return");
            return;
        }
        
        if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
            LogInfo(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] failed, server returns no no data update info, return");
            return;
        }
        
        
       
        // 7. 将数据库中相关数据标为有更新
        {
            for (id obj in response.updateInfo.details) {
                ServerResponseUpdateInfoDetail *detail = (ServerResponseUpdateInfoDetail *)obj;
                if (detail == nil) {
                    continue;
                }
                //获取数据的状态
                NSString *needUpdateApp = [NSString stringWithFormat:@"%@",[detail valueForKey:@"need_update_app"]];
                NSString *isPermissioned = [NSString stringWithFormat:@"%@",[detail valueForKey:@"is_permissioned"]];
                NSString *dataId = [detail valueForKey:@"data_id"];
                NSString *updateInfo = [detail valueForKey:@"update_info"];
                NSString *dataLatestVersion = [detail valueForKey:@"data_version_latest"];
                
                //判断服务器返回的各种状态，根据状态修改数据库中的DataStatus字段
                if ([needUpdateApp isEqualToString:@"1"]) {
                    //app版本过低
                    BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:APP_VERSION_LOW andDataStatusDescTo:updateInfo forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                     LogInfo(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
                }
                else if ([needUpdateApp isEqualToString:@"2"]) {
                    //app版本过高
                    BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:APP_VERSION_HIGH andDataStatusDescTo:updateInfo forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                     LogInfo(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
                }
                else if ([isPermissioned isEqualToString:@"0"]) {
                    //没有权限
                    BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:NO_PERMISSION andDataStatusDescTo:updateInfo forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                     LogInfo(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
                }
                else {
                
//  1.0 setter             BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_DETECTED andDataStatusDescTo:updateInfo forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                    //2.0 setter
                    BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_DETECTED andDataStatusDescTo:updateInfo andDataLatestVersion:dataLatestVersion andDataPath:nil andDataStorageType:DATA_STORAGE_INTERNAL_STORAGE forDataWithDataId:dataId andType:DATA_TYPE_DATA_SOURCE];
                    
                LogInfo(@"[KnowledgeDataManager-getUpdateInfoFileFromServerAndUpdateDataBase] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
                }
                
                
                
            }
        }
        /*
        //8.由更新模式决定是否需要自动更新
        if ([Config instance].knowledgeDataConfig.knowledgeDataUpdateMode == DATA_UPDATE_MODE_CHECK_AND_UPDATE) {
            [self startDownloadWithResponse:response];
        }
        */
    });
         
        return YES;
      
}
                  






#pragma mark check update self

 //check data update, and auto apply update
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
//        if (response == nil || response.updateInfo == nil || response.updateInfo.status < 0) {
//            LogError(@"[KnowledgeDataManager-startCheckDataUpdate:] failed to get data update info, return");
//            return;
//        }
//        
//        if (response.updateInfo.details == nil || response.updateInfo.details.count <= 0) {
//            LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate:] failed, server returns no no data update info, return");
//            return;
//        }
//        
//        // 5. 将数据库中相关数据标为有更新
//        {
//            for (id obj in response.updateInfo.details) {
//                ServerResponseUpdateInfoDetail *detail = (ServerResponseUpdateInfoDetail *)obj;
//                if (detail == nil || [detail.needUpdateApp isEqualToString:@"0"]) {
//                    continue;
//                }
//                
//                NSString *dataId = [detail valueForKey:@"id"];
//                BOOL retVal = [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_DETECTED andDataStatusDescTo:detail.updateInfo forDataWithDataId:detail.dataId andType:DATA_TYPE_DATA_SOURCE];
//                LogInfo(@"[KnowledgeDataManager-startCheckDataUpdate:] %@ to mark data %@ as having update", (retVal ? @"successfully" : @"failed"), dataId);
//            }
//        }
//        
//        // 6. 根据更新模式, 启动后台下载, 下载完成后, 自动完成更新
//        // 注: 后续操作位于KnowledgeDownloadManagerDelegate的相关方法中. 包括: (1) 解包 (2) 拷贝文件, 更新数据库
////        if ([Config instance].knowledgeDataConfig.knowledgeDataUpdateMode == DATA_UPDATE_MODE_CHECK_AND_UPDATE) {
//            [self startDownloadWithResponse:response];
////        }
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
        //把一行直接转成一个对象？
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
    
//    NSInteger curAppVersionNum = [AppUtil getAppVersionNum];
    NSString *curAppVersionStr = [AppUtil getAppVersionStr];//2.0中服务器返回版本号为2.0.0.0
    if (curAppVersionStr < 0) {
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
        // 确定数据的当前版本 --- 这个数据是从数据库中获取到的到的
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
//                    NSInteger appVersionNumMin = [dataVersionInfo.appVersionMin intValue];
//                    if (curAppVersionNum < appVersionNumMin) {
                    if ([curAppVersionStr compare:dataVersionInfo.appVersionMin] < 0) {
                        shouldUpdate = NO;
                    }
                }
                //app_version_Max最大版本号还没有上限
//                if (shouldUpdate && (dataVersionInfo.appVersionMax != nil
              /*                       && dataVersionInfo.appVersionMax.length > 0)) {
                if (shouldUpdate) {
//                    NSInteger appVersionNumMax = [dataVersionInfo.appVersionMax intValue];
//                    if (curAppVersionNum > appVersionNumMax) {
                    if ([curAppVersionStr compare:dataVersionInfo.appVersionMax] > 0) {
                        shouldUpdate = NO;
                    }
                }
                */
            }
        }
        //此处修改了-正确的判断应该是shouldUpdate
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
    
    // body params --2.0中post请求体中的参数修改了部分内容。
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
//    [data setValue:userAgent forKey:@"user_agent"];
    [data setValue:@"0" forKey:@"encrypt_method"]; // 对称加密
    [data setValue:@"0" forKey:@"encrypt_key_type"];
    [data setValue:@"1" forKey:@"app_platform"]; // ios
    [data setValue:@"" forKey:@"g_user_id"];
    
    
    
    {
        NSString *appVersion = [NSString stringWithFormat:@"%@",[AppUtil getAppVersionStr]];
        [data setValue:appVersion forKey:@"app_version"]; // app version
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
            //修改了dataInfo，易出错点
            NSString *json = [dataInfo toJSONString];
            NSLog(@"warning -- 易出错点:knowledgeDataManager - getDataUpdataInfo:%@",json);
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
        /*
        // 对称加密
        NSString *encryptedContent = [cryptUtil encryptAES128:jsonOfDataUpdateRequestInfo];
        if (encryptedContent == nil || encryptedContent.length <= 0) {
            lastError = @"数据加密失败";
            return nil;
        }
        */
        LogDebug(@"[KnowledgeDataManager-getDataUpdateInfo -- look is json String:] encryptedContent: %@", jsonOfDataUpdateRequestInfo);
//        [data setValue:encryptedContent forKey:@"data"];
        //data对应的需要是一个json字符串，浩哥上述操作是拼接了一个json格式的字符串
        [data setValue:jsonOfDataUpdateRequestInfo forKey:@"data"];
    }
    
    
    // 发送web请求, 获取响应
    NSString *serverResponseStr = [WebUtil sendRequestTo:[NSURL URLWithString:url] usingVerb:@"POST" withHeader:headers andData:data];
    if (serverResponseStr == nil || serverResponseStr.length <= 0) {
        lastError = @"网络请求失败";
        return nil;
    }
    
    //2.0：可以获取到服务器的响应信息。
    // 解析响应: json=>obj,将服务器的响应转换成一个objc对象。
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
    else if (response.encryptMethod == 0) {
        if (response.encryptKeyType == 0) {
            decryptedContent = [response.data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
    
    LogInfo(@"[knowledgeDataManager - getDataUpdateInfo:] ===== %@",lastError);
    return response;
}
            

#pragma mark - KnowledgeDownloadManagerDelegate methods

// 下载进度
- (void)knowledgeDownloadItem:(KnowledgeDownloadItem *)downloadItem didProgress:(float)progress {
    LogDebug(@"download item, id %@, title %@, progress: %@", downloadItem.itemId, downloadItem.title, downloadItem.downloadProgress);
    
    // 将下载进度更新到coreData
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_IN_PROGRESS andDataStatusDescTo:[NSString stringWithFormat:@"%lf", progress] forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
        NSLog(@"进度=====%lf",progress -10);
    });
    //H：自己方便写
    [self.dataStatusDelegate DownLoadKnowledgedataWithProgress:progress andDownloadItem:downloadItem];
}
        
// 下载成功/失败
// 注：下载，解包，删除多余文件组成一个整体的操作，下载完成后将进度减去10，解包和删除压缩文件的操作占总进度的10%
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
        //下载失败
        LogWarn(@"knowledgeDataManager -- knoeledgeDownloadItem:didFinish:response:  download failed");
        // 1、将下载失败的信息存储到数据库中
        // 1、2 若是在更新过程中下载失败，需要将数据状态置为可更新，以便用户能够继续阅读旧的书籍
//        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *knowledgeDataInDocument = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
        NSString *originalBookPath = [NSString stringWithFormat:@"%@/%@",knowledgeDataInDocument,downloadItem.title];
        BOOL originalBookExist = [[NSFileManager defaultManager] fileExistsAtPath:originalBookPath];
        if (originalBookExist) {//在指定目录下有对应的书存在，则认定为是更新操作
            [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_UPDATE_DETECTED andDataStatusDescTo:@"更新时，下载失败" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
        }else {
            //非更新时，下载失败
            [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_FAILED andDataStatusDescTo:@"0" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
        }
        
//        });
        // 2、下载失败后，要将已经下载的内容清除掉
        BOOL isDir;
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:self.globalSavePath isDirectory:&isDir];
        if (existed) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL removeSuccess = [fileManager removeItemAtPath:self.globalSavePath error:nil];
            
        }
        
        return;
    }
    
    // 将下载进度更新到coreData
    
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[KnowledgeMetaManager instance] setDataStatusTo:DATA_STATUS_DOWNLOAD_COMPLETED andDataStatusDescTo:@"90" forDataWithDataId:downloadItem.title andType:DATA_TYPE_DATA_SOURCE];
//    });
    
    // 启动后台任务, 继续下载的后续操作
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processDownloadedDataPack:downloadItem];
    });
    
    
    //H:使用代理，将下载完成的状态值传到knowledgeManager中
    [self.dataStatusDelegate DownLoadKnowledgedata:success andDownLoadItem:downloadItem];
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
            if (data && data.length > 0 && ![searchedArray containsObject:data]) {
                [searchedArray addObject:data];
            }
        }
    }

    // 3. 返回所有数据
    return searchedArray;
}

#pragma mark  - 2.0 get book list
- (NSArray *)getBookList:(NSString *)bookCategory {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] getKnowledgeMetaWithBookCategory:bookCategory];
    if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
        return nil;
    }
    //从每个entity中取以下内容
    //{book_id, book_category, book_status, cur_version, book_meta_json}
    for (NSManagedObject *entity in knowledgeMetas) {
        if (entity == nil) {
            continue;
        }
        NSString *bookId = nil;
        NSString *booKcategory = nil;
        NSString *bookStatus = nil;
        NSString *bookStatusStr = nil;
        NSString *curVersion = nil;
        NSString *bookMeta = nil;
        NSString *bookReadType = nil;
        NSString *completeBookId = nil;
        bookId = [entity valueForKey:@"dataId"];
        booKcategory = [entity valueForKey:@"bookCategory"];
        bookStatus = [entity valueForKey:@"dataStatus"];
        bookReadType = [entity valueForKey:@"bookReadType"];
        completeBookId = [entity valueForKey:@"completeBookId"];
        //转换成int来判断
        int bookStatusInt = [bookStatus intValue];
        if (bookStatusInt >= 1 && bookStatusInt <= 3) {
            bookStatusStr = @"下载中";
        }
        else if (bookStatusInt == 7) {
            bookStatusStr = @"可更新";
        }
        else if (bookStatusInt == 8 || bookStatusInt ==9) {
            bookStatusStr = @"更新中";
        }
        else if (bookStatusInt == 10) {
            bookStatusStr = @"完成";
        }
        else if (bookStatusInt == 11) {
            bookStatusStr = @"APP版本过低";
        }
        else if (bookStatusInt == 12) {
            bookStatusStr = @"APP版本过高";
        }
        else if (bookStatusInt == 14) {
            bookStatusStr = @"下载失败";
        }
        else if (bookStatusInt == 15) {
            bookStatusStr = @"下载暂停";
        }
        else if (bookStatusInt == -1  || bookStatusInt > 15) {
            bookStatusStr = @"未下载";
        }
        
        
        curVersion = [entity valueForKey:@"curVersion"];
        bookMeta = [entity valueForKey:@"bookMeta"];
        //组成dic
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:bookId forKey:@"book_id"];
        [dic setValue:booKcategory forKey:@"book_category"];
        [dic setValue:bookReadType forKey:@"book_read_type"];
        [dic setValue:completeBookId forKey:@"complete_book_id"];
        [dic setValue:bookStatusStr forKey:@"book_status"];
        [dic setValue:curVersion forKey:@"cur_version"];
        [dic setValue:bookMeta forKey:@"book_meta_json"];
        
        //
        [arr addObject: dic];
        
    }
    //转成json string
    return  arr;
    
}

#pragma mark 判断解压可能出现的错误
- (BOOL)checkResultWithFilePath:(NSString *)unpackDataPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL unpackSuccess = YES;
    //1 判断解压完成后具体书籍的目录是否存在
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:unpackDataPath isDirectory:&isDir];
    if (!existed) {
        unpackSuccess = NO;
        return unpackSuccess;
    }
    //2 目录存在，判断目录下是否有具体的分目录存在
    NSError *error = nil;
    NSArray *subDirsInUnpackDataPath = [fileManager contentsOfDirectoryAtPath:unpackDataPath error:&error];
    if (subDirsInUnpackDataPath == nil || subDirsInUnpackDataPath.count <= 0) {
        unpackSuccess = NO;
        return unpackSuccess;
    }
    //3 判断shit文件是否为0，解压失败是出现的错误一般是：目录结构完好，但是具体每个文件的大小都为0
    NSString *shitFilePath = [NSString stringWithFormat:@"%@/%@/%@",unpackDataPath,@"data",@"shit"];
    //判断shit文件是否存在
    BOOL shitExisted = [fileManager fileExistsAtPath:shitFilePath];
    if (!shitExisted) {
        unpackSuccess = NO;
        return unpackSuccess;
    }
    //判断shit文件大小是否为0
    NSString *shitFileContents = [NSString stringWithContentsOfFile:shitFilePath encoding:NSUTF8StringEncoding error:&error];
    if (shitFileContents == nil || shitFileContents.length <= 0) {
        unpackSuccess = NO;
        return unpackSuccess;
    }
        return unpackSuccess;
}


#pragma mark 删除试读书 



@end
