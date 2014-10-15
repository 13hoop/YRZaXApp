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
#import "KnowledgeDataManager.h"
#import "KnowledgeSearchManager.h"
#import "KnowledgeDownloadManager.h"

#import "UserManager.h"

#import "LoginViewController.h"

#import "PathUtil.h"
#import "CoreDataUtil.h"



// KnowledgeManager
@interface KnowledgeManager() <KnowledgeDataStatusDelegate> {
    
}

// init
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode;
- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs;

- (BOOL)knowledgeDataInited;
- (BOOL)updateKnowledgeDataInitFlag:(BOOL)value;

// register data files
- (BOOL)registerDataFiles;

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
            break;
        case KNOWLEDGE_DATA_INIT_MODE_SYNC:
            [self initKnowledgeDataSync];
            break;
        default:
            break;
    }
    
    return TRUE;
}

- (BOOL)initKnowledgeDataSync {
    BOOL shouldInit = ![self knowledgeDataInited];
    if (shouldInit) {
        [[KnowledgeDataManager instance] copyAssetsKnowledgeData];
        [self registerDataFiles];
        [self updateKnowledgeDataInitFlag:YES];
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
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    
    // 遍历meta.json
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:knowledgeDataRootPathInDocuments];
    NSString *path = nil;
    while ((path = [dirEnum nextObject]) != nil) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInDocuments, path];
        
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

#pragma mark - remote data methods
- (BOOL)tryDownloadDataByDataId:(NSString *)dataId andName:(NSString *)dataName {
    // todo: 必须是登录用户才能下载
    UserInfo *curUser = [[UserManager instance] getCurUser];
    
//    if (curUser == nil) {
//        // 用户未登录，跳转到登陆页面
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"信息" message:@"登录用户才能离线下载书籍哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alertView show];
//        
//        // 用户为登录，跳转到登陆页面
//        LoginViewController *loginViewController =
//        
//        self.
//        Intent intent = new Intent(getActivity(), UserLoginActivity.class);
//        getActivity().startActivity(intent);
//        return NO;
//    }
//    int network = DeviceUtil.getNetworkType(getActivity());
//    if (network == DeviceUtil.NETWORK_INVALID) {
//        // 没有网络
//        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
//        builder.setPositiveButton("OK",
//                                  new DialogInterface.OnClickListener() {
//                                      
//                                      @Override
//                                      public void onClick(DialogInterface dialog, int arg1) {
//                                          // Auto-generated method stub
//                                          dialog.cancel();
//                                      }
//                                  });
//        builder.setMessage("当前没有网络，请打开网络");
//        AlertDialog alertDialog = builder.create();
//        alertDialog.show();
//        return OK;
//    }
//    if (network == DeviceUtil.NETWORK_WIFI) {
//        // wifi下，直接下载，不提示
//        theKnowledgeManager.getRemoteData(getActivity(), id,
//                                          DataType.DATA_TYPE_DATA_SOURCE);
//        return OK;
//    }
//    // 2G/3G/4G 网络，提示用户是否下载
//    AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
//    builder.setPositiveButton("立即下载",
//                              new DialogInterface.OnClickListener() {
//                                  
//                                  @Override
//                                  public void onClick(DialogInterface dialog, int arg1) {
//                                      // Auto-generated method stub
//                                      dialog.cancel();
//                                      theKnowledgeManager.getRemoteData(getActivity(), id,
//                                                                        DataType.DATA_TYPE_DATA_SOURCE);
//                                  }
//                              });
//    builder.setNegativeButton("暂不下载",
//                              new DialogInterface.OnClickListener() {
//                                  
//                                  @Override
//                                  public void onClick(DialogInterface dialog, int arg1) {
//                                      // Auto-generated method stub
//                                      dialog.cancel();
//                                  }
//                              });
//    builder.setMessage("《" + nodeName + "》 还没有下载到本地，是否现在下载？");
//    AlertDialog alertDialog = builder.create();
//    alertDialog.show();
//    return OK;
    
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
        
        NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
        NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInDocuments, knowledgeMetaEntity.dataPath];
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

#pragma mark - data update
// check data update
- (BOOL)startCheckDataUpdate {
    return [[KnowledgeDataManager instance] startUpdateData];
}

#pragma mark -
#pragma mark - test
- (void)test {
    NSLog(@"[KnowledgeManager - test()], starting...");
    
//    [[KnowledgeDownloadManager instance] test];
    
//    return;
    
    [[KnowledgeDataManager instance] copyAssetsKnowledgeData];
    [self registerDataFiles];
    
    NSString *dataIdForPagePath = @"3b7942bf7d9f8a80dc3b7e43539ee40e";
    NSString *dataId = @"2a8ceed5e71a0ff16bafc9f082bceeec";
    NSString *searchId = @"210101";
    
    // local
    {
//        NSString *pagePath = [self getPagePath:dataIdForPagePath];
//        NSString *localData = [self getLocalData:dataId];
//        NSString *searchResult = [self searchLocalData:searchId];
    }
    
    // remote - download
//    BOOL ret = [self getRemoteData:dataId];
    
    // remote - update
    BOOL ret = [self startCheckDataUpdate];
    
    NSLog(@"[KnowledgeManager - test()], end");
}

@end
