//
//  KnowledgeManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeManager.h"

#import "Config.h"

#import "KnowledgeMetaEntity.h"
#import "KnowledgeSearchEntity.h"
#import "KnowledgeMetaManager.h"
#import "KnowledgeDataLoader.h"
#import "KnowledgeDataManager.h"
#import "KnowledgeSearchManager.h"
#import "KnowledgeDownloadManager.h"

#import "UserManager.h"

#import "LoginViewController.h"

#import "AppUtil.h"
#import "PathUtil.h"
#import "CoreDataUtil.h"
#import "MD5Util.h"
#import "CryptUtil.h"
#import "SecurityUtil.h"
#import "LogUtil.h"
#import "TimeWatcher.h"
#import "SBJsonWriter.h"
#import "KnowledgeDataTypes.h"

// KnowledgeManager
@interface KnowledgeManager() <KnowledgeDataStatusDelegate> {
   
}

// init
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode;
//- (BOOL)initKnowledgeDataAsync;
//- (BOOL)initKnowledgeDataSync;

- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs;

//- (BOOL)knowledgeDataInited;
- (BOOL)updateKnowledgeDataInitFlag:(BOOL)value;


@end


@implementation KnowledgeManager

#pragma mark - singleton
+ (KnowledgeManager *)instance {
    static KnowledgeManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
//        [sharedInstance initKnowledgeData:[[Config instance] knowledgeDataConfig].knowledgeDataInitMode];
        [sharedInstance initKnowledgeUpdater:[[Config instance] knowledgeDataConfig].knowledgeUpdateCheckIntervalInMs];
    });
    
    return sharedInstance;
}

#pragma mark - init knowledge data
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode {
    switch(mode) {
        case KNOWLEDGE_DATA_INIT_MODE_NONE:
            break;
        case KNOWLEDGE_DATA_INIT_MODE_ASYNC:
            [self initKnowledgeDataAsync];
            break;
        case KNOWLEDGE_DATA_INIT_MODE_SYNC:
            [self initKnowledgeDataSync];
            break;
        default:
            break;
    }
    
    return TRUE;
}

- (BOOL)initKnowledgeDataAsync {
    // 启动后台任务
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initKnowledgeDataSync];
    });
    
    return YES;
}

- (BOOL)initKnowledgeDataSync {
    BOOL shouldInit = ![self knowledgeDataInited];
    if (shouldInit) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dataInitStartedWithResult:andDesc:)]) {
            [self.delegate dataInitStartedWithResult:YES andDesc:@"初始化数据..."];
        }
        
        TimeWatcher *timeWatcher = [[TimeWatcher alloc] init];
        [timeWatcher start];
        
        // 不再拷贝
        //        [[KnowledgeDataManager instance] copyAssetsKnowledgeData];
        [self registerDataFiles];
        [self updateKnowledgeDataInitFlag:YES]; // comment out for test
        
        [timeWatcher stop];
        NSString *info = [timeWatcher getIntervalStr];
        LogDebug(@"[KnowledgeManager-initKnowledgeDataSync] 耗时: %@", info);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dataInitEndedWithResult:andDesc:)]) {
            [self.delegate dataInitEndedWithResult:YES andDesc:@"数据初始化完成"];
        }
    }
    
    return YES;
}

- (BOOL)knowledgeDataInited {
    BOOL inited = YES;
    
    do {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL knowledgeInited = [userDefaults boolForKey:[[Config instance] knowledgeDataConfig].keyForKnowledgeDataInitedFlag];
        if (!knowledgeInited) {
            inited = NO;
            break;
        }
        
        NSString *initedOnAppVersion = [userDefaults stringForKey:[Config instance].knowledgeDataConfig.keyForKnowledgeDataInitAppVersion];
        NSString *curAppVersion = [AppUtil getAppVersionStr];
        if ((initedOnAppVersion == nil && curAppVersion) ||
            ![initedOnAppVersion isEqualToString:curAppVersion]) {
            inited = NO;
            break;
        }
    } while (0);
    
    return inited;
}

- (BOOL)updateKnowledgeDataInitFlag:(BOOL)value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // 写初始化标记
    [userDefaults setBool:value forKey:[[Config instance] knowledgeDataConfig].keyForKnowledgeDataInitedFlag];
    
    // 写app版本号
    NSString *curAppVersion = [AppUtil getAppVersionStr];
    [userDefaults setObject:curAppVersion forKey:[Config instance].knowledgeDataConfig.keyForKnowledgeDataInitAppVersion];
    
    return YES;
}

#pragma mark - register data files
//- (BOOL)registerDataFiles {
//    // 1. 清除已有的knowledge metas
//    [[KnowledgeMetaManager instance] clearKnowledgeMetas];
//    
//    // 2. 写入新的knowledge metas
//    NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
//    
//    // 遍历meta.json
//    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:knowledgeDataRootPathInApp];
//    NSString *path = nil;
//    while ((path = [dirEnum nextObject]) != nil) {
//        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInApp, path];
//        
//        BOOL isDir = NO;
//        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
//        if (isDir) {
//            continue;
//        }
//        
//        // 若为meta.json
//        if ([fullPath hasSuffix:[Config instance].knowledgeDataConfig.knowledgeMetaFilename]) {
//            // 构造KnowledgeMeta对象
//            NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] loadKnowledgeMeta:fullPath];
//            if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
//                continue;
//            }
//            
//            for (id obj in knowledgeMetas) {
//                KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
//                if (knowledgeMeta == nil) {
//                    continue;
//                }
//                
//                // 保存到db
//                [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
//                LogDebug(@"[KnowledgeManager-registerDataFiles] registered file: %@", fullPath);
//            }
//        }
//    }
//    
//    return YES;
//}

- (BOOL)registerDataFiles {
    // 1. 清除已有的knowledge metas
    [[KnowledgeMetaManager instance] clearKnowledgeMetas];
    
    // 2. 写入新的knowledge metas
    NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
    
    // 收集需要处理的meta.json
    NSMutableArray *metasToProcess = [[NSMutableArray alloc] init];
    
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:knowledgeDataRootPathInApp];
    NSString *path = nil;
    while ((path = [dirEnum nextObject]) != nil) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInApp, path];
        
        BOOL isDir = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
        if (isDir) {
            continue;
        }
        
        // 若为meta.json
        if ([fullPath hasSuffix:[Config instance].knowledgeDataConfig.knowledgeMetaFilename]) {
            [metasToProcess addObject:fullPath];
        }
    }
    
    // 遍历meta.json
    for (int i = 0; i < metasToProcess.count; ++i) {
        NSString *fullPath = metasToProcess[i];
        if (fullPath == nil || [fullPath isEqualToString:@""]) {
            continue;
        }
        
        float progressValue = ((i + 1) * 100.0f) / metasToProcess.count;
        NSNumber *progress = [NSNumber numberWithFloat:progressValue];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dataInitEndedWithResult:andDesc:)]) {
            [self.delegate dataInitProgressChangedTo:progress withDesc:@"初始化数据"];
        }
        
        // 构造KnowledgeMeta对象
        NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] loadKnowledgeMeta:fullPath];
        if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
            continue;
        }
        
        for (id obj in knowledgeMetas) {
            KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
            if (knowledgeMeta == nil) {
                continue;
            }
            
            // 保存到db
            [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
            LogDebug(@"[KnowledgeManager-registerDataFiles] registered file: %@", fullPath);
        }
    }
    
    return YES;
}

#pragma mark register  book data info for 2.0
- (BOOL)registerBookMetaInfo:(NSDictionary *)partialBookMeta {
    // 1. 清除已有的knowledge metas   不能清空数据库
//    [[KnowledgeMetaManager instance] clearKnowledgeMetas];
    //2、解析发现页请求获得的dic
    if (partialBookMeta == nil) {
        LogInfo(@"knowledgemanager - registerBookMetaInfo : partialBookMeta is nil");
        return NO;
    }
    //3、构造KnowledgeMeta对象
    KnowledgeMeta *knowledgeMeta = [KnowledgeMeta parseBookMetaDic:partialBookMeta];
    if (knowledgeMeta == nil) {
        return NO;
    }
    //
    //5、保存到db
     BOOL ret = [[KnowledgeMetaManager instance] saveKnowledgeMeta:knowledgeMeta];
    LogDebug(@"[KnowledgeManager-registerBookMetaInfo] registered file ");
    return ret;
}


#pragma mark - init knowledge updater
- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs {
    
    return TRUE;
}

#pragma mark - methods for js call
/*
// get page path
- (NSString *)getPagePath:(NSString *)pageId withDataStoreLocation:(NSString *)dataStoreLocation {
    NSArray *metaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:pageId];
//    NSArray *metaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:pageId andDataType:DATA_TYPE_DATA_SOURCE];
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    
    // 返回首个
    for (id obj in metaArray) {
        KnowledgeMetaEntity *knowledgeMetaEntity = (KnowledgeMetaEntity *)obj;
        if (knowledgeMetaEntity == nil) {
            continue;
        }
        
        //H:修改
        NSString *knowledgeDataRootPathInApp = nil;
        if (dataStoreLocation == nil || dataStoreLocation.length <=0 ||[dataStoreLocation isEqualToString:@"appBundle"]) {
            knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
//            knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
        }
        else {
            
            if ([dataStoreLocation isEqualToString:@"sandBox"]) {
                //H:修改到沙盒中目录下：
                knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
                NSLog(@"第一：加载沙盒中的html页面===%@",knowledgeDataRootPathInApp);
            }
            
        }
        
        NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInApp, knowledgeMetaEntity.dataPath];
        return fullFilePath;
    }
    
    return nil;
}
 */
//H:支持从sandBox和bundle目录下获取：
- (NSString *)getPagePath:(NSString *)pageId {
    NSArray *metaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:pageId];
//        NSArray *metaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:pageId andDataType:DATA_TYPE_DATA_SOURCE];
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    
    // 返回首个
    for (id obj in metaArray) {
        KnowledgeMetaEntity *knowledgeMetaEntity = (KnowledgeMetaEntity *)obj;
        if (knowledgeMetaEntity == nil) {
            continue;
        }
        
        /*
         H:修改说明 （1）加载app自带的meta的文件到数据库时，dataStorageType赋值为：DATA_STORAGE_APP_ASSETS
         更新后的数据将这个字段设为DATA_STORAGE_INTERNAL_STORAGE。
                   （2）为了能够分别找到bundle目录下的文件和sandBox目录下的文件，需要根据dataStorageType字段来判断。
         */
        
        //判断最新数据是在app中还是sandBox中
        NSString *knowledgeDataRootPathInApp = nil;
        if ([knowledgeMetaEntity.dataStorageType isEqualToNumber:[NSNumber numberWithInteger:DATA_STORAGE_APP_ASSETS]]) {
//            knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
            knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;

             NSLog(@"读取Bundle下的html页面和数据===%@",knowledgeDataRootPathInApp);
        }
        else {
            
            if ([knowledgeMetaEntity.dataStorageType isEqualToNumber:[NSNumber numberWithInteger:DATA_STORAGE_INTERNAL_STORAGE]]) {
                //H:修改到沙盒中目录下：
                knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
                NSLog(@"读取sandBox中的html页面和数据===%@",knowledgeDataRootPathInApp);
            }
            
        }
        
        NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInApp, knowledgeMetaEntity.dataPath];
        return fullFilePath;
    }
    
    return nil;

}


#pragma mark - local data fetch
// get local data
- (NSString *)getLocalData:(NSString *)dataId {
    NSArray *metaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    
    for (id obj in metaArray) {
        KnowledgeMetaEntity *knowledgeMetaEntity = (KnowledgeMetaEntity *)obj;
        if (knowledgeMetaEntity == nil) {
            continue;
        }
        
        return [[KnowledgeDataManager instance] loadKnowledgeData:knowledgeMetaEntity];
    }
    
    return nil;
}

// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSArray *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename {
    return [[KnowledgeDataManager instance] getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
}

#pragma mark - remote data fetch

// get remote data
- (BOOL)getRemoteData:(NSString *)dataId {
    return [[KnowledgeDataManager instance] startDownloadData:dataId];
}


#pragma mark - data status delegate
- (BOOL)knowledgeData:(NSString *)dataId downloadedToPath:(NSString *)dataPath successfully:(BOOL)succ {
    return YES;
}

- (BOOL)knowledgeDataAtPath:(NSString *)dataPath updatedSuccessfully:(BOOL)succ {
    return YES;
}
//H:
- (void)isShouldUpdateWithUpdateMessage:(NSString *)updateMessage {
    [self.delegate isShouldUpdateWithUpdateMessage:updateMessage];
}
- (BOOL)DownLoadKnowledgedata:(BOOL)isSuccess andDownLoadItem:(KnowledgeDownloadItem *)downloadItem {
    [self.delegate knowledgeDownloadManagerIsSuccess:isSuccess andDownloadItem:downloadItem];
    return YES;
}
- (BOOL)DownLoadKnowledgedataWithProgress:(float)progress andDownloadItem:(KnowledgeDownloadItem *)downloadItem {
    [self.delegate knowledgeDownloadManagerWithProgress:progress andDownloadItem:downloadItem];
    return YES;
}
//代理传值
- (BOOL)returnUpdatableDataVersionInfo:(NSArray *)updatableDataVersionInfoArray {
    //代理属性调用代理方法
    return [self.delegate returnUpdatableDataVersionInfoArrayManager:updatableDataVersionInfoArray];
    
}
//备用--promopt
- (BOOL)returnPromptInformationToJSWithInformation:(NSString *)promptInfo {
    return [self.delegate returnPromptInformationToJSWithInformation:promptInfo];
}
#pragma mark - local data search
//// search data
//- (NSString *)searchLocalData:(NSString *)searchId {
//    NSArray *knowledgeSearchEntities = [[KnowledgeSearchManager instance] searchData:searchId];
//    if (knowledgeSearchEntities == nil || knowledgeSearchEntities.count <= 0) {
//        return nil;
//    }
//    
//    NSMutableString *searchResult = [[NSMutableString alloc] init];
//    [searchResult appendString:@"["];
//    
//    BOOL isFirst = YES;
//    for (id obj in knowledgeSearchEntities) {
//        KnowledgeSearchEntity *knowledgeSearchEntity = (KnowledgeSearchEntity *)obj;
//        if (knowledgeSearchEntity == nil || knowledgeSearchEntity.dataId == nil || knowledgeSearchEntity.dataId.length <= 0) {
//            continue;
//        }
//        
//        NSString *data = [self getLocalData:knowledgeSearchEntity.dataId];
//        if (data == nil || data.length <= 0) {
//            continue;
//        }
//        
//        if (isFirst) {
//            isFirst = NO;
//        }
//        else {
//            [searchResult appendString:@","];
//        }
//        [searchResult appendString:data];
//    }
//    
//    [searchResult appendString:@"]"];
//    
//    return searchResult;
//}






// search data
- (NSString *)searchLocalData:(NSString *)searchId {
    NSArray *knowledgeSearchResults = [[KnowledgeDataManager instance] searchData:searchId];
    if (knowledgeSearchResults == nil || knowledgeSearchResults.count <= 0) {
        return @"[]";
    }
    
    return [NSString stringWithFormat:@"[%@]", [knowledgeSearchResults componentsJoinedByString:@","]];
}

// get data status
- (NSString *)getDataStatus:(NSString *)dataId {
    NSString *status = @"";
    
    NSArray *knowledgeMetas = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
    if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
        return status;
    }
    
    for (id obj in knowledgeMetas) {
        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
        if (knowledgeMeta == nil) {
            continue;
        }
        
        status = [NSString stringWithFormat:@"%d/%@", knowledgeMeta.dataStatus, knowledgeMeta.dataStatusDesc];
        break;
    }
    
    return status;
}

#pragma mark - data update
// check data update
- (BOOL)startCheckDataUpdate {
    //为了2.0修改了
    return [[KnowledgeDataManager instance] startUpdateData];
   
}

#pragma mark -
#pragma mark - test
- (void)test {
    LogInfo(@"[KnowledgeManager-test()], starting...");
    
    // 1. 测试加密, 保证多次加密得到的字符串一致
//    {
//        NSString *plainText = @"1234567890abcdefgABCDEFG";
//        
//        NSString *password = @"1234567890";
//        NSString *key = [MD5Util md5ForString:password];
//        NSString *iv = [MD5Util md5ForString:key];
//        CryptUtil *cryptUtil = [[CryptUtil alloc] initWithKey:key andIV:iv];
//        for (int i = 0; i < 10; ++i) {
//            NSString *encryptedText1 = [cryptUtil encryptAES128:plainText];
//            LogInfo(@"==>%d, encryptedText1: %@", i, encryptedText1);
//            
//            NSString *encryptedText2 = [SecurityUtil AES128Encrypt:plainText andwithPassword:password];
//            LogInfo(@"==>%d, encryptedText2: %@", i, encryptedText2);
//        }
//        
//        return;
//    }
    
    // 2. KnowledgeDownloadManager自测
//    [[KnowledgeDownloadManager instance] test];
//    return;
    
    // 3. 数据拷贝测试
//    [[KnowledgeDataManager instance] copyAssetsKnowledgeData];
//    [self registerDataFiles];
    
    NSString *dataIdForPagePath = @"3b7942bf7d9f8a80dc3b7e43539ee40e";
    NSString *dataId = @"2a8ceed5e71a0ff16bafc9f082bceeec";
    NSString *searchId = @"210101";
    
    // 4. 本地数据获取测试
    // local
//    {
//        NSString *pagePath = [self getPagePath:dataIdForPagePath];
//        NSString *localData = [self getLocalData:dataId];
//        NSString *searchResult = [self searchLocalData:searchId];
//    }
    
    // 5. 远程数据获取测试
    // remote - download
//    BOOL ret = [self getRemoteData:dataId];
    
    // 6. 数据更新测试
    // remote - update
//    BOOL ret = [self startCheckDataUpdate];
    
    // 10. knowledge loader测试
//    {
////    BOOL ret = [[KnowledgeDataLoader instance] test];
//        NSString *dataId = @"9999eed5e71a0ff16bafc9f082bc9999";
//        NSString *queryId = @"0";
//
//        //    NSString *knowledgeDataRootPathInAssets = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;
//        NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
//        NSString *indexFilename = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInDocuments, @"kaoyan^book_index_data^english#english_realexam_2010/index_8"];
//
//        NSString *data = [self getLocalDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
//        LogInfo(@"[KnowledgeManager-test()] got data: %@ for dataId: %@, and queryId: %@, andIndexFilename:%@", data, dataId, queryId, indexFilename);
//    }
    
    // 11. crash report test
    {
        char *p = NULL;
        memset(p, 100, sizeof(char));
    }
    
    LogInfo(@"[KnowledgeManager-test()], end");
}


#pragma mark - 2.0 getBookList
- (NSArray *)getBookList:(NSString *)bookCategoy {
    NSArray *bookListArr = [[KnowledgeDataManager instance] getBookList:bookCategoy];
    return bookListArr;
}


#pragma mark H:check update self method

//H:从服务器获取数据更新信息，并同本地版本比较，获取更新信息。
- (BOOL)getUpdateInfoFileFromServerAndUpdateDataBase {
    //
    [KnowledgeDataManager instance].dataStatusDelegate = self;
    return [[KnowledgeDataManager instance] getUpdateInfoFileFromServerAndUpdateDataBase];
}
//H:下载一本新书
- (BOOL)startDownloadDataManagerWithDataId:(NSString *)dataId {
   return [[KnowledgeDataManager instance] startDownloadDataWithDataId:dataId];
}
//H:根据js传来的参数进行解析
- (NSString *)getUpdateInfoFormDataBaseWithDataString:(NSString *)dataString {
    //需要修改
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:(NSData *)dataString options:0 error:nil];
    //for 循环遍历 and 拼成json字符串
    NSString *dataId = [dic objectForKey:@"dataId"];
    DataStatus dataStatus = DATA_STATUS_UPDATE_DETECTED;
    NSArray *dataIdArr = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataStatus:dataStatus];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *updatableDataStr = [writer stringWithObject:dataIdArr];
    return updatableDataStr;
}

//set download pause status
- (void)modifyDataStatusWithDataType {
    [[KnowledgeMetaManager instance] setDataStatusforDataWithDataType:DATA_TYPE_DATA_SOURCE];
}
@end
