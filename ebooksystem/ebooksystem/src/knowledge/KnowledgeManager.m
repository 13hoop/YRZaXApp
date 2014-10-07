//
//  KnowledgeManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/2/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeManager.h"
#import "Config.h"
#import "PathUtil.h"
#import "KnowledgeMetaManager.h"



// KnowledgeManager
@interface KnowledgeManager() {
    
}

// init
- (BOOL)initKnowledgeData:(KnowledgeDataInitMode)mode;
- (BOOL)initKnowledgeUpdater:(int)updateIntervalInMs;

- (BOOL)knowledgeDataInited;
- (BOOL)updateKnowledgeDataInitFlag:(BOOL)value;

// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData;

// copy data files
- (BOOL)copyFilesFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

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
        [self copyAssetsKnowledgeData];
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

#pragma mark - copy data files
// 将assets目录下的knowledge data拷贝到目标路径
- (BOOL)copyAssetsKnowledgeData {
    NSString *knowledgeDataRootPathInAssets = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInAssets;
    NSString *knowledgeDataRootPathInDocuments = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments;
    
    BOOL ret = [PathUtil copyFilesFromPath:(NSString *)knowledgeDataRootPathInAssets toPath:(NSString *)knowledgeDataRootPathInDocuments];
    
    return ret;
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
        if ([fullPath hasSuffix:@"meta.json"]) {
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


#pragma mark -
#pragma mark - test
- (void)test {
    NSLog(@"[KnowledgeManager - test()], starting...");
    
    [self copyAssetsKnowledgeData];
    [self registerDataFiles];
    
    NSLog(@"[KnowledgeManager - test()], end");
}

@end
