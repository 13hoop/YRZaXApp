//
//  BookMarkMetaManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/3.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "BookMarkMetaManager.h"
#import "CoreDataUtil.h"
#import "LogUtil.h"
#import "UUIDUtil.h"

@implementation BookMarkMetaManager

+ (BookMarkMetaManager *)instance {
    static BookMarkMetaManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[BookMarkMetaManager alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - save  && add bookMark meta
- (BOOL)saveBookMarkMeta:(BookMarkMeta *)bookMarkMeta {
    if (bookMarkMeta == nil) {
        return NO;
    }
    
    BOOL saved = NO;
    
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    // 1. try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookMarkEntity" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookMarkId==%@",bookMarkMeta.bookMarkId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                BOOL ret = [bookMarkMeta setValuesForEntity:entity];
                if (!ret) {
                    LogError(@"[BookMarkMetaManager::saveBookMarkMeta()] update failed because of BookMarkMeta::setValuesForEntity() error");
                    return NO;
                }
                
                NSError *error = nil;
                if (![context save:&error]) {
                    LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
            }
            
            saved = YES;
        }
    }
    
    // 2. insert as new
    if (saved == NO) {
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"BookMarkEntity" inManagedObjectContext:context];
        
        BOOL ret = [bookMarkMeta setValuesForEntity:entity];
        if (!ret) {
            LogError(@"[BookMarkMetaManager::saveBookMetaEntity()] insert failed because of BookMarkMeta::setValuesForEntity() error");
            return NO;
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            LogError(@"[BookMarkMetaManager::saveBookMetaEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
            return NO;
        }
    }
    
    return YES;

    
    
}

#pragma mark get book mark meta

//get book mark by bookId , bookMarkId
- (NSArray *)getBookMarkMetaWithBookId:(NSString *)bookId andBookMarkId:(NSString *)bookMarkId{
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookMarkEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and bookMarkId=%@", bookId, bookMarkId];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
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


//get book mark by bookId , bookMarkType ,queryId
- (NSArray *)getBookMarkMetaWithBookId:(NSString *)bookId andBookMarkType:(NSString *)bookMarkType andQueryId:(NSString *)queryId {
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookMarkEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Predicate
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and bookMarkType=%@ and targetId=%@", bookId, bookMarkType,queryId];
    NSPredicate *predicate = [self generatePredicateByBookId:bookId andBookMarkType:bookMarkType andQueryId:queryId];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
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

//根据三个参数值是否为空，构造查询predicate对象
- (NSPredicate *)generatePredicateByBookId:(NSString *)bookId andBookMarkType:(NSString *)bookMarkType andQueryId:(NSString *)queryId {
    
    //bookId不为空时会调用这个方法，若bookId为空时，直接获取所有的书签
        if (bookMarkType == nil || bookMarkType.length <= 0) {//bookMarkType 为空
            
                if (queryId == nil || queryId.length <= 0) {//queryId 为空,bookMarkType 为空，bookId不为空
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId=%@",bookId];
                    return predicate;
                }
                else { // queryId 不为空,bookMarkType 为空,bookId 不为空
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and targetId=%@",bookId,queryId];
                    return predicate;
                }
            }
        
        else {//bookMarkType 不为空
            
            if (queryId == nil || queryId.length <= 0) { //bookMarkType 不为空，queryId为空 bookId 不为空
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and bookMarkType=%@",bookId,bookMarkType];
                return predicate;
            }
            else { //bookMarkType 不为空，queryId 不为空, bookId 不为空
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and bookMarkType=%@ and targetId=%@",bookId,bookMarkType,queryId];
                return predicate;
            }
        }
        
    
    return nil;
}

//查询所有的书签 
- (NSArray *)getAllBookMark {
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
     NSEntityDescription *entity=[NSEntityDescription entityForName:@"BookMarkEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
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







#pragma mark delete bookMark meta

//delete bookMark meta by bookid ,bookMarkId
- (BOOL)deleteBookMarkMetaWithBookId:(NSString *)bookId andBookMarkId:(NSString *)bookMarkId {
    NSArray *knowledgeMetaEntities = [self getBookMarkMetaWithBookId:bookId andBookMarkId:bookMarkId];
    if (knowledgeMetaEntities == nil || knowledgeMetaEntities.count <= 0) {
        return YES; // nothing to delete, return YES
    }
    
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    
    for (id entity in knowledgeMetaEntities) {
        [context deleteObject:entity];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        LogError(@"[BookMarkMetaManager-deleteBookMarkMetaWithBookId:andBookMarkId:] failed when save to context, error: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

#pragma mark - setter && update info
//update book mark's bookMarkName bookMarkContent targetId
- (BOOL)updateBookMarkMetaWithLatestBookMarkUpdateInfo:(NSDictionary *)updateDic {
    
    NSString *bookMarkId = [updateDic valueForKey:@"bookmark_id"];
    NSString *bookMarkType = [updateDic valueForKey:@"type"];
    
    if (bookMarkId == nil || bookMarkId.length <= 0 || bookMarkType == nil || bookMarkType.length <= 0 ) {
        return NO;
    }
    
    BOOL saved = NO;
    
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    
    //  try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookMarkEntity" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // Predicate
        //bookMarkId是一定传过来的。
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookMarkId=%@",bookMarkId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                if (entity == nil) {
                    continue;
                }
                
                //bookMarkName
                {
                    NSString *bookMarkName = [updateDic valueForKey:@"bookmark_name"];
                    if (bookMarkName != nil && bookMarkName.length > 0) {
                        //不为空，则更新数据库中的值
                        [entity setValue:bookMarkName forKey:@"bookMarkName"];
                    }
                }
                
                //bookMarkContent
                {
                    NSString *bookMarkContent = [updateDic valueForKey:@"bookmark_content"];
                    if (bookMarkContent != nil && bookMarkContent.length > 0) {
                        //不为空，则更新数据库中的该字段，否则保留原有的值。
                        [entity setValue:bookMarkContent forKey:@"bookMarkContent"];
                    }
                }
                //targetId
                {
                    NSString *targetId = [updateDic valueForKey:@"target_id"];
                    if (targetId != nil && targetId.length > 0) {
                        [entity setValue:targetId forKey:@"targetId"];
                    }
                }
                //bookId
                {
                    NSString *bookId = [updateDic valueForKey:@"book_id"];
                    if (bookId != nil && bookId.length > 0) {
                        [entity setValue:bookId forKey:@"bookId"];
                    }
                }
                //updatetime
                NSDate *upadteDate = [NSDate date];
                [entity setValue:upadteDate forKey:@"updateBookMarkTime"];
                
                
                //save
                if (![context save:&error]) {
                    LogError(@"[BookMarkMetaManager-updateBookMarkMetaWithLatestBookMarkUpdateInfo:] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
                
            }
            
            saved = YES;
        }
    }
    
    return saved;

    
}


//二维码扫描时会调用该方法，更新bookMarkEntity实体
- (BOOL)updateBookMarkMetaProgressWithProgressInfo:(scanResultItem *)scanItem {
    
    NSString *bookId = scanItem.bookIdInMap;
    
    if (bookId == nil || bookId.length <= 0 ) {
        return NO;
    }
    
    BOOL saved = NO;
    
    NSManagedObjectContext *context = [CoreDataUtil instance].recordDataContext;
    
    //  try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"BookMarkEntity" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // Predicate
        //在每本书中bookMarkType为progress的记录是唯一的。根据bookId、bookMarkType能唯一确定一条记录。
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId=%@ and bookMarkType=%@",bookId,@"progress"];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                if (entity == nil) {
                    continue;
                }
                
                //bookMarkContent {book_id,query_id,tab_id}
                {
                    NSString *bookMarkContent = scanItem.pageArgsInMap;
                    if (bookMarkContent != nil && bookMarkContent.length > 0) {
                        //不为空，则更新数据库中的该字段，否则保留原有的值。
                        [entity setValue:bookMarkContent forKey:@"bookMarkContent"];
                    }
                }
                //targetId 就是QR_map文件中的queryId
                {
                    NSString *targetId = scanItem.queryIdInMap;
                    if (targetId != nil && targetId.length > 0) {
                        [entity setValue:targetId forKey:@"targetId"];
                    }
                }
                //updatetime
                NSDate *upadteDate = [NSDate date];
                [entity setValue:upadteDate forKey:@"updateBookMarkTime"];
                
                
                //save
                if (![context save:&error]) {
                    LogError(@"[BookMarkMetaManager-updateBookMarkMetaWithLatestBookMarkUpdateInfo:] update failed when save to context, error: %@", [error localizedDescription]);
                    return NO;
                }
                
            }
            
            saved = YES;
        }
    }
    
    // 2. insert as new 可能已经下载了一本书，但是没有看过，通过扫描二维码直接进到这本书，此时需要生成UUID插入到数据库中。而不是更新
    if (saved == NO) {
        
        BookMarkMeta *bookMarkItem = [[BookMarkMeta alloc] init];
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"BookMarkEntity" inManagedObjectContext:context];
        
        
       
        NSString *UUID = [NSString stringWithFormat:@"%@", [UUIDUtil getUUID]];
        bookMarkItem.bookMarkId = UUID; //这里将UUID存到bookMarkId中
        bookMarkItem.bookId = scanItem.bookIdInMap;
        bookMarkItem.targetId = scanItem.queryIdInMap;
        bookMarkItem.createBookMarkTime = [NSDate date];
        bookMarkItem.bookMarkContent = scanItem.pageArgsInMap;
        bookMarkItem.bookMarkType = @"progress";
        bookMarkItem.updateBookMarkTime = [NSDate date];
        //guserId在最底层来判断，逻辑：每次存储bookMarkMeta时需要取当前的用户的userId,若是有则存到数据库中国，反之将数据库中的guserId字段置为空。
        
        
        
        BOOL ret = [bookMarkItem setValuesForEntity:entity];
        if (!ret) {
            LogError(@"[BookMarkMetaManager::saveBookMetaEntity()] insert failed because of BookMarkMeta::setValuesForEntity() error");
            return NO;
        }学习就欧诺个
        
        NSError *error = nil;
        if (![context save:&error]) {
            LogError(@"[BookMarkMetaManager::saveBookMetaEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
            return NO;
        }
    }

    
    
    return saved;

}


@end
