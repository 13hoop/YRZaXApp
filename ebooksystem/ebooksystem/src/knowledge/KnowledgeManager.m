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

#import "PathUtil.h"
#import "CoreDataUtil.h"
#import "MD5Util.h"
#import "CryptUtil.h"
#import "SecurityUtil.h"
#import "LogUtil.h"



// KnowledgeManager
@interface KnowledgeManager() <KnowledgeDataStatusDelegate> {
    
}

// init
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode;
- (BOOL)initKnowledgeDataAsync;
- (BOOL)initKnowledgeDataSync;

- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs;

- (BOOL)knowledgeDataInited;
- (BOOL)updateKnowledgeDataInitFlag:(BOOL)value;


@end


@implementation KnowledgeManager

#pragma mark - singleton
+ (KnowledgeManager *)instance {
    static KnowledgeManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initKnowledgeData:[[Config instance] knowledgeDataConfig].knowledgeDataInitMode];
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
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        
        // 不再拷贝
//        [[KnowledgeDataManager instance] copyAssetsKnowledgeData];
        [self registerDataFiles];
        [self updateKnowledgeDataInitFlag:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dataInitEndedWithResult:andDesc:)]) {
            [self.delegate dataInitEndedWithResult:YES andDesc:@"数据初始化数据完成"];
        }
    }
    
    return YES;
}

- (BOOL)knowledgeDataInited {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL knowledgeInited = [userDefaults boolForKey:[[Config instance] knowledgeDataConfig].keyForKnowledgeDataInitedFlag];
    return knowledgeInited;
}

- (BOOL)updateKnowledgeDataInitFlag:(BOOL)value {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:[[Config instance] knowledgeDataConfig].keyForKnowledgeDataInitedFlag];
    return YES;
}

#pragma mark - register data files
- (BOOL)registerDataFiles {
    NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
    
    // 遍历meta.json
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
            }
        }
    }
    
    return YES;
}

#pragma mark - init knowledge updater
- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs {
    
    return TRUE;
}

#pragma mark - methods for js call
// get page path
- (NSString *)getPagePath:(NSString *)dataId {
    NSArray *metaArray = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId andDataType:DATA_TYPE_DATA_SOURCE];
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    
    // 返回首个
    for (id obj in metaArray) {
        KnowledgeMetaEntity *knowledgeMetaEntity = (KnowledgeMetaEntity *)obj;
        if (knowledgeMetaEntity == nil) {
            continue;
        }
        
        NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
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
- (NSString *)getLocalDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename {
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

#pragma mark - local data search
// search data
- (NSString *)searchLocalData:(NSString *)searchId {
    NSArray *knowledgeSearchEntities = [[KnowledgeSearchManager instance] searchData:searchId];
    if (knowledgeSearchEntities == nil || knowledgeSearchEntities.count <= 0) {
        return nil;
    }
    
    NSMutableString *searchResult = [[NSMutableString alloc] init];
    [searchResult appendString:@"["];
    
    BOOL isFirst = YES;
    for (id obj in knowledgeSearchEntities) {
        KnowledgeSearchEntity *knowledgeSearchEntity = (KnowledgeSearchEntity *)obj;
        if (knowledgeSearchEntity == nil || knowledgeSearchEntity.dataId == nil || knowledgeSearchEntity.dataId.length <= 0) {
            continue;
        }
        
        NSString *data = [self getLocalData:knowledgeSearchEntity.dataId];
        if (data == nil || data.length <= 0) {
            continue;
        }
        
        if (isFirst) {
            isFirst = NO;
        }
        else {
            [searchResult appendString:@","];
        }
        [searchResult appendString:data];
    }
    
    [searchResult appendString:@"]"];
    
    return searchResult;
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
    [[KnowledgeDataManager instance] copyAssetsKnowledgeData];
    [self registerDataFiles];
    
    NSString *dataIdForPagePath = @"3b7942bf7d9f8a80dc3b7e43539ee40e";
    NSString *dataId = @"2a8ceed5e71a0ff16bafc9f082bceeec";
    NSString *searchId = @"210101";
    
    // 4. 本地数据获取测试
    // local
    {
//        NSString *pagePath = [self getPagePath:dataIdForPagePath];
//        NSString *localData = [self getLocalData:dataId];
//        NSString *searchResult = [self searchLocalData:searchId];
    }
    
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
//    {
//        char *p = NULL;
//        memset(p, 100, sizeof(char));
//    }
    
    LogInfo(@"[KnowledgeManager-test()], end");
}

@end
