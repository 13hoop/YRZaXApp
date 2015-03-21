//
//  KnowledgeDataConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataConfig.h"

#import "Config.h"

#import "PathUtil.h"



@interface KnowledgeDataConfig()

// knowledge data的根目录名
@property (nonatomic, copy) NSString *knowledgeDataRootDirName;
// knowledge data下载目录的根目录名
@property (nonatomic, copy) NSString *knowledgeDataDownloadRootDirName;

@end




@implementation KnowledgeDataConfig

@synthesize dataUrlForDownload;
@synthesize dataUrlForVersion;
@synthesize dataUrlForUpdate;

@synthesize keyForKnowledgeDataInitedFlag = _keyForKnowledgeDataInitedFlag;
@synthesize keyForKnowledgeDataInitAppVersion = _keyForKnowledgeDataInitAppVersion;

@synthesize knowledgeDataRootPathInAssets = _knowledgeDataRootPathInAssets;
@synthesize knowledgeDataRootPathInDocuments = _knowledgeDataRootPathInDocuments;
@synthesize knowledgeDataRootPathInApp = _knowledgeDataRootPathInApp;
@synthesize knowledgeDataRootDirName = _knowledgeDataRootDirName;
@synthesize knowledgeDataDownloadRootPathInDocuments = _knowledgeDataDownloadRootPathInDocuments;

@synthesize knowledgeDataFilename = _knowledgeDataFilename;
@synthesize knowledgeMetaFilename = _knowledgeMetaFilename;

@synthesize knowledgeDataInitMode = _knowledgeDataInitMode;
@synthesize knowledgeUpdateCheckIntervalInMs = _knowledgeUpdateCheckIntervalInMs;

@synthesize knowledgeDataUpdateMode = _knowledgeDataUpdateMode;


#pragma mark - properties
- (NSString *)dataUrlForDownload {
//    return @"http://www.zaxue100.com/index.php?c=check_update_ctrl&m=get_version";
    return [NSString stringWithFormat:@"http://%@/index.php?c=check_update_ctrl&m=get_version", [Config instance].appConfig.httpDomain];
}

- (NSString *)dataUrlForVersion {
//    return @"http://sdata.zaxue100.com/kaoyan/app-update-pack/kaoyan_data_version.json";
//    return [NSString stringWithFormat:@"http://%@/kaoyan/app-update-pack/kaoyan_data_version.json", [Config instance].appConfig.httpDomainForData];
//    return @"http://112.126.75.224:9713/index.php?c=check_update_platform_ctrl&m=get_download_url";
//    return @"http://112.126.75.224:8296/ios_kaoyan_data_version.json";
//    return @"http://test.zaxue100.com/update_check/ios_data_version.json";
//    return @"http://7u2rlu.com2.z0.glb.qiniucdn.com/ios_data_version.json";
    return @"http://test.zaxue100.com/ios_data_version.json";
}

- (NSString *)dataUrlForUpdate {
//    return @"http://www.zaxue100.com/index.php?c=check_update_ctrl&m=get_update";
//    return [NSString stringWithFormat:@"http://%@/index.php?c=check_update_ctrl&m=get_update", [Config instance].appConfig.httpDomain];
    NSString *urlStr = [@"http://www.zaxue100.com/index.php?c=check_update_platform_ctrl&m=get_download_url" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return urlStr;
    
    
}

#pragma mark - singleton
+ (KnowledgeDataConfig *)instance {
    static KnowledgeDataConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

#pragma mark - knowledge data

// knowledge inited flag key, for storing in user defaults
- (NSString *)keyForKnowledgeDataInitedFlag {
    return @"knowledge_data_inited";
}

// app version key, for storing in user defaults
- (NSString *)keyForKnowledgeDataInitAppVersion {
    return @"knowledge_data_inited_on_app_version";
}

// knowledge data root path in assets
- (NSString *)knowledgeDataRootPathInAssets {
    if (_knowledgeDataRootPathInAssets == nil) {
        NSString *bundlePath = [PathUtil getBundlePath];
        _knowledgeDataRootPathInAssets = [NSString stringWithFormat:@"%@/%@/%@", bundlePath, @"assets", self.knowledgeDataRootDirName];
    }
    
    return _knowledgeDataRootPathInAssets;
}

// knowledge data root path in sandbox
- (NSString *)knowledgeDataRootPathInDocuments {
    if (_knowledgeDataRootPathInDocuments == nil) {
        NSString *documentsPath = [PathUtil getDocumentsPath];
        
        _knowledgeDataRootPathInDocuments = [NSString stringWithFormat:@"%@/%@", documentsPath, self.knowledgeDataRootDirName];
    }
    return _knowledgeDataRootPathInDocuments;
}

// knowledge data root path in sandbox
// app中的数据根目录, (1) 若app自带全量数据, 则为asset/knowledge_data目录; (2) 若app未自带全量数据, 则为Documents/knowledge_data目录.
- (NSString *)knowledgeDataRootPathInApp {
    NSString *path = nil;
    
    switch ([Config instance].appConfig.appMode) {
        case APP_WITH_FULL_DATA:
            path = [self knowledgeDataRootPathInAssets];
            break;
            
        case APP_WITHOUT_FULL_DATA:
            path = [self knowledgeDataRootPathInDocuments];
            break;
            
        default:
            break;
    }
    
    return path;
}

// knowledge data download root path in sandbox
- (NSString *)knowledgeDataDownloadRootPathInDocuments {
    if (_knowledgeDataDownloadRootPathInDocuments == nil) {
        NSString *documentsPath = [PathUtil getDocumentsPath];
        
        _knowledgeDataDownloadRootPathInDocuments = [NSString stringWithFormat:@"%@/%@", documentsPath, self.knowledgeDataDownloadRootDirName];
    }
    return _knowledgeDataDownloadRootPathInDocuments;
}


- (NSString *)knowledgeDataRootDirName {
    return @"knowledge_data";
}

- (NSString *)knowledgeDataDownloadRootDirName {
    return @"download";
}

- (NSString *)knowledgeDataFilename {
    return @"data.json";
}

- (NSString *)knowledgeMetaFilename {
    return @"meta.json";
}

- (KnowledgeDataInitMode)knowledgeDataInitMode {
//    return KNOWLEDGE_DATA_INIT_MODE_NONE;
    return KNOWLEDGE_DATA_INIT_MODE_SYNC;
//    return KNOWLEDGE_DATA_INIT_MODE_ASYNC;
}

- (int)knowledgeUpdateCheckIntervalInMs {
    return 60 * 60 * 1000;
}

- (DataUpdateMode)knowledgeDataUpdateMode {
    return DATA_UPDATE_MODE_CHECK;
//        return DATA_UPDATE_MODE_CHECK_AND_UPDATE;
}


@end
