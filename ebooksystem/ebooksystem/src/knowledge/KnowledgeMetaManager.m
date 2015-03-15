//
//  KnowledgeMetaManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/7/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeMetaManager.h"

#import "KnowledgeSearchReverseInfo.h"

#import "CoreDataUtil.h"
#import "LogUtil.h"



@interface KnowledgeMetaManager()


#pragma mark - methods
// save knowledge meta as knowledge meta entity
- (BOOL)saveKnowledgeMetaEntity:(KnowledgeMeta *)knowledgeMeta;

// save knowledge meta as knowledge search entity
- (BOOL)saveKnowledgeSearchEntity:(KnowledgeMeta *)knowledgeMeta;


@end




@implementation KnowledgeMetaManager

#pragma mark - singleton
+ (KnowledgeMetaManager *)instance {
    static KnowledgeMetaManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[KnowledgeMetaManager alloc] init];
    });
    
    return sharedInstance;
}


// load knowledge meta
- (NSArray *)loadKnowledgeMeta:(NSString *)fullFilePath {
    NSMutableArray *knowledgeMetas = [[NSMutableArray alloc] init];
    
    // read file line by line
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&error];
    if (fileContents == nil || fileContents.length <= 0) {
        LogError(@"[KnowledgeMetaManager::loadKnowledgeMeta()]failed, file: %@, error: %@", fullFilePath, error.localizedDescription);
        return nil;
    }
    
    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    if (lines == nil || lines.count <= 0) {
        return nil;
    }
    
    NSEnumerator *enumerator = [lines objectEnumerator];
    NSString *curLine = nil;
    while ((curLine = [enumerator nextObject]) != nil) {
        KnowledgeMeta *knowledgeMeta = [KnowledgeMeta parseJsonString:curLine];
        if (knowledgeMeta != nil) {
            [knowledgeMetas addObject:knowledgeMeta];
        }
    }
    
    return knowledgeMetas;
}

// save knowledge meta
- (BOOL)saveKnowledgeMeta:(KnowledgeMeta *)knowledgeMeta {
    if (knowledgeMeta == nil) {
        return YES; // nothing to save, return YES
    }
    
    BOOL ret = [self saveKnowledgeMetaEntity:knowledgeMeta];
    if (!ret) {
        return ret;
    }
    
    ret = [self saveKnowledgeSearchEntity:knowledgeMeta];
    
    return ret;
}

// save knowledge meta as knowledge meta entity
- (BOOL)saveKnowledgeMetaEntity:(KnowledgeMeta *)knowledgeMeta {
    if (knowledgeMeta == nil) {
        return YES; // nothing to save, return YES
    }
    
    BOOL saved = NO;
    // 1. try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", knowledgeMeta.dataId, [NSNumber numberWithInteger:knowledgeMeta.dataType]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                BOOL ret = [knowledgeMeta setValuesForEntity:entity];
                if (!ret) {
                    LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] update failed because of knowledgeMeta::setValuesForEntity() error");
                    return NO;
                }
                
                NSError *error = nil;
                if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                    LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
            }
            
            saved = YES;
        }
    }
    
    // 2. insert as new
    if (saved == NO) {
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
        
        BOOL ret = [knowledgeMeta setValuesForEntity:entity];
        if (!ret) {
            LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] insert failed because of knowledgeMeta::setValuesForEntity() error");
            return NO;
        }
        
        NSError *error = nil;
        if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
            LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
            return NO;
        }
    }
    
    return YES;
}

// save knowledge meta as knowledge search entity
- (BOOL)saveKnowledgeSearchEntity:(KnowledgeMeta *)knowledgeMeta {
    if (knowledgeMeta == nil || knowledgeMeta.searchReverseInfo == nil || knowledgeMeta.searchReverseInfo.count <= 0) {
        return YES; // nothing to save, return YES
    }
    
    NSError *error = nil;
    for (id obj in knowledgeMeta.searchReverseInfo) {
        KnowledgeSearchReverseInfo *knowledgeSearchReverseInfo = (KnowledgeSearchReverseInfo *)obj;
        if (knowledgeSearchReverseInfo == nil || knowledgeSearchReverseInfo.searchId == nil || knowledgeSearchReverseInfo.searchId.length <= 0 || knowledgeSearchReverseInfo.searchResults == nil || knowledgeSearchReverseInfo.searchResults.count <= 0) {
            continue;
        }
        
        for (id searchResultItemObj in knowledgeSearchReverseInfo.searchResults) {
            KnowledgeSearchResultItem *knowledgeSearchResultItem = (KnowledgeSearchResultItem *)searchResultItemObj;
            if (knowledgeSearchResultItem == nil) {
                continue;
            }
            
            BOOL saved = NO;
            // 1. try update if exists
            {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                
                // Entity
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeSearchEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
                [fetchRequest setEntity:entity];
                
                // Predicate
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchId==%@", knowledgeSearchReverseInfo.searchId];
                [fetchRequest setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects != nil &&
                    fetchedObjects.count > 0) {
                    // 若已有, 更新
                    for (NSManagedObject *entity in fetchedObjects) {
//                        [entity setValue:knowledgeSearchReverseInfo.searchId forKey:@"searchId"];
                        [entity setValue:knowledgeSearchResultItem.dataId forKey:@"dataId"];
                        [entity setValue:knowledgeSearchResultItem.dataNameEn forKey:@"dataNameEn"];
                        [entity setValue:knowledgeSearchResultItem.dataNameCh forKey:@"dataNameCh"];
                        
                        NSError *error = nil;
                        if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                            LogError(@"[KnowledgeMetaManager::saveKnowledgeSearchEntity()] update failed when save to context, error: %@", [error localizedDescription]);
                            return NO;
                        }
                    }
                    
                    saved = YES;
                }
            }
            
            // 2. insert as new
            if (saved == NO) {
                // create entity
                NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"KnowledgeSearchEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
                
                [entity setValue:knowledgeSearchReverseInfo.searchId forKey:@"searchId"];
                [entity setValue:knowledgeSearchResultItem.dataId forKey:@"dataId"];
                [entity setValue:knowledgeSearchResultItem.dataNameEn forKey:@"dataNameEn"];
                [entity setValue:knowledgeSearchResultItem.dataNameCh forKey:@"dataNameCh"];
                
                // save
                if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                    LogError(@"[KnowledgeMetaManager::saveKnowledgeSearchEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

// delete knowledge meta
- (BOOL)deleteKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType {
    NSArray *knowledgeMetaEntities = [self getKnowledgeMetaWithDataId:dataId andDataType:dataType];
    if (knowledgeMetaEntities == nil || knowledgeMetaEntities.count <= 0) {
        return YES; // nothing to delete, return YES
    }
    
    for (id entity in knowledgeMetaEntities) {
        [[CoreDataUtil instance].managedObjectContext deleteObject:entity];
    }
    
    NSError *error = nil;
    if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
        LogError(@"[KnowledgeMetaManager-deleteKnowledgeMetaWithDataId:andDataType:] failed when save to context, error: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

// clear knowledge metas
- (BOOL)clearKnowledgeMetas {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            [[CoreDataUtil instance].managedObjectContext deleteObject:entity];
        }
    }
    
    if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
        LogError(@"[KnowledgeMetaManager-clearKnowledgeMetas] failed when save to context, error: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

#pragma mark - get knowledge meta


//get knowledge metas by dataType
//app启动时根据dataType来查询数据库，确定book_id对应的dataStatus是否处于未下载状态
- (NSArray *)getKnowledgeMetaWithDataType:(DataType)dataType {
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataType=%@", dataType];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            [metaArray addObject:entity];
        }
    }
    
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    return metaArray;
}






// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId {
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@", dataId];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            [metaArray addObject:entity];
        }
    }
    
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    return metaArray;
}

// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType {
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            [metaArray addObject:entity];
        }
    }
    
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    return metaArray;
}

/*
//获取数据的状态
- (NSUInteger)getDataStatusWithDataId:(NSString *)dataId {
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@", dataId];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            if (entity == nil) {
                continue;
            }
            KnowledgeMeta *bookMeta = [KnowledgeMeta fromKnowledgeMetaEntity:entity];
            NSUInteger dataStatus = entity.
        }
    }
}
*/


// get knowledge data version
- (NSString *)getKnowledgeDataVersionWithDataId:(NSString *)dataId andDataType:(DataType)dataType {
    NSArray *knowledgeMetas = [self getKnowledgeMetaWithDataId:dataId andDataType:dataType];
    if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
        return nil;
    }
    
    // 确定数据的当前版本
    NSString *dataCurVersion = nil;
    for (id obj in knowledgeMetas) {
        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
        if (knowledgeMeta == nil) {
            continue;
        }
        
        dataCurVersion = knowledgeMeta.curVersion;
        break;
    }
    
    return dataCurVersion;
}


//get knowdgeMeta version according to dataId only
- (NSString *)getKnowledgeDataVersionWithDataId:(NSString *)dataId {
//    NSArray *knowledgeMetas = [self getKnowledgeMetaWithDataId:dataId andDataType:dataType];
    NSArray *knowledgeMetas = [self getKnowledgeMetaWithDataId:dataId];
    if (knowledgeMetas == nil || knowledgeMetas.count <= 0) {
        return nil;
    }
    
    // 确定数据的当前版本
    NSString *dataCurVersion = nil;
    for (id obj in knowledgeMetas) {
        KnowledgeMeta *knowledgeMeta = (KnowledgeMeta *)obj;
        if (knowledgeMeta == nil) {
            continue;
        }
        
        dataCurVersion = knowledgeMeta.curVersion;
        break;
    }
    
    return dataCurVersion;
}




//H:get knowledge metas with dataId and dataStatus
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataStatus:(DataStatus)dataStatus {
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate  -----根据dataId和dataStatus获取knowledgeMetas
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataStatus=%@", dataId, [NSNumber numberWithInteger:dataStatus]];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            [metaArray addObject:entity];
        }
    }
    
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    return metaArray;

}

//  2.0 get knowledge meta according to bookCategory
- (NSArray *)getKnowledgeMetaWithBookCategory:(NSString *)bookCategory {
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate  -----根据bookcategory来构造查询条件,查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookCategory=%@",bookCategory];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            [metaArray addObject:entity];
        }
    }
    
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    return metaArray;
}










#pragma mark - setter
// 更新数据的状态及状态描述
- (BOOL)setDataStatusTo:(DataStatus)status andDataStatusDescTo:(NSString *)desc forDataWithDataId:(NSString *)dataId andType:(DataType)dataType {
    if (dataId == nil) {
        return YES; // nothing to save, return YES
    }
    
    BOOL saved = NO;
    // 1. try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                [entity setValue:[NSNumber numberWithInteger:status] forKey:@"dataStatus"];
                
                // dataStatusDesc
                {
                    NSString *dataStatusDesc = ((desc == nil || desc.length <= 0) ? @"" : desc);
                    [entity setValue:dataStatusDesc forKey:@"dataStatusDesc"];
                }
                
                // updateInfo
                {
                    // 检测到有更新时, 将更新信息也记录到updateInfo
                    if (status == DATA_STATUS_UPDATE_DETECTED) {
                        NSString *updateInfo = ((desc == nil || desc.length <= 0) ? @"" : desc);
                        [entity setValue:updateInfo forKey:@"updateInfo"];
                    }
                }
                
                if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                    LogError(@"[KnowledgeMetaManager-setDataStatusTo:andDataStatusDescTo:forDataWithDataId:andType:] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
            }
            
            saved = YES;
        }
    }
    
    return saved;
}









// get searchable knowledge metas
- (NSArray *)getSearchableKnowledgeMetas {
    NSMutableArray *knowledgeMetas = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataSearchType==%d", DATA_SEARCH_SEARCHABLE];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            KnowledgeMetaEntity *knowledgeMetaEntity = (KnowledgeMetaEntity *)entity;
            if (!knowledgeMetaEntity) {
                continue;
            }
            
            KnowledgeMeta *knowledgeMeta = [KnowledgeMeta fromKnowledgeMetaEntity:knowledgeMetaEntity];
            if (knowledgeMeta) {
                [knowledgeMetas addObject:knowledgeMeta];
            }
        }
    }
    
    return knowledgeMetas;
}

#pragma mark setter for 2.0
//H2.0:1获取到服务器的response 2将解压后的目录移动到指定目录下时会调用的方法
- (BOOL)setDataStatusTo:(DataStatus)status andDataStatusDescTo:(NSString *)desc andDataLatestVersion:(NSString *)latestVersion andDataPath:(NSString *)dataPath andDataStorageType:(DataStorageType)dataStorageType forDataWithDataId:(NSString *)dataId andType:(DataType)dataType {
    if (dataId == nil) {
        return YES; // nothing to save, return YES
    }
    
    BOOL saved = NO;
    // 1. try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                [entity setValue:[NSNumber numberWithInteger:status] forKey:@"dataStatus"];
                [entity setValue:[NSNumber numberWithInteger:dataStorageType] forKey:@"dataStorageType"];
                // dataStatusDesc
                {
                    NSString *dataStatusDesc = ((desc == nil || desc.length <= 0) ? @"" : desc);
                    [entity setValue:dataStatusDesc forKey:@"dataStatusDesc"];
                }
                
                // updateInfo
                {
                    // 检测到有更新时, 将更新信息也记录到updateInfo
                    if (status == DATA_STATUS_UPDATE_DETECTED) {
                        NSString *updateInfo = ((desc == nil || desc.length <= 0) ? @"" : desc);
                        [entity setValue:updateInfo forKey:@"updateInfo"];
                    }
                }
                // latestVersion
                {
                    // 在获取到数据的最新版本号时将数据的版本号存到数据库的latestVersion字段
                    if (status == DATA_STATUS_UPDATE_DETECTED) {
                        NSString *latestVersionStr = ((latestVersion == nil || latestVersion.length <= 0) ? @"" : latestVersion);
                        [entity setValue:latestVersionStr forKey:@"latestVersion"];
                    }
                }
                //将latestVersion字段值赋值给curVersion字段
                {
                    if (status == DATA_STATUS_UPDATE_COMPLETED) {
                        NSString *latestVersionStr = [entity valueForKey:@"latestVersion"];
                        [entity setValue:latestVersionStr forKey:@"curVersion"];
                    }
                }
                //dataPath
                {
                    //将第一次下载、更新下载的文件移动到指定目录下后将文件所在的相对路径保存到数据库
                    if (status == DATA_STATUS_UPDATE_COMPLETED) {
                        NSString *dataPathStr = ((dataPath == nil || dataPath.length <= 0) ? @"" : dataPath);
                        [entity setValue:dataPathStr forKey:@"dataPath"];
                    }
                }
                
                
                if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                    LogError(@"[KnowledgeMetaManager-setDataStatusTo:andDataStatusDescTo:forDataWithDataId:andType:] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
            }
            
            saved = YES;
        }
    }
    
    return saved;
}

//检查数据的状态和数据的下载进度，修改数据的状态
- (BOOL)setDataStatusforDataWithDataType:(DataType)dataType {
    
    BOOL saved = NO;
    
    // 1. try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataType=%@", [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[CoreDataUtil instance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                if (entity == nil) {
                    continue;
                }
                NSString *progress = [entity valueForKey:@"dataStatusDesc"];
                NSNumber *curDataStatusNum = [entity valueForKey:@"dataStatus"];
                int curDataStatus = [curDataStatusNum intValue];
                LogInfo(@"curDataStatus===========================%d",curDataStatus);
                if ([progress isEqualToString:@"100"]==NO && curDataStatus != 10) {
                    //dataStatus不等于DATA_STATUS_UPDATE_COMPLETED（10），progress不等于100，则设置为下载暂停的状态
                    
                    [entity setValue:[NSNumber numberWithInteger:DATA_STATUS_DOWNLOAD_PAUSE] forKey:@"dataStatus"];
                }
                //save
                if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                    LogError(@"[KnowledgeMetaManager-setDataStatusTo:andDataStatusDescTo:forDataWithDataId:andType:] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
                
            }
            
            saved = YES;
        }
    }
    
    return saved;

}



@end
