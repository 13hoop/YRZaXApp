//
//  UserDataMetaManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/4/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "UserDataMetaManager.h"
#import "CoreDataUtil.h"
#import "LogUtil.h"
#import "NSUserDefaultUtil.h"


#define DEBUGMODE
@implementation UserDataMetaManager

#pragma mark - singleton单例
+ (UserDataMetaManager *)instance {
  
    static UserDataMetaManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[UserDataMetaManager alloc] init];
    });
    
    return sharedInstance;
    
}

#pragma mark - save && update userData meta
- (BOOL)saveUserDataMeta:(UserDataMeta *)userDataMeta {
    if (userDataMeta == nil) {
        return NO;
    }
    
    BOOL saved = NO;
    //使用tempConetxt来实现读写数据库
    NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];
    // 1. try update if exists
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Entity
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserDataEntity" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId==%@ and k1=%@ and k2=%@ and k3=%@ and k4=%@ and k5=%@ and type=%@",userDataMeta.userId,userDataMeta.k1,userDataMeta.k2,userDataMeta.k3,userDataMeta.k4,userDataMeta.k5,userDataMeta.type];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects != nil &&
            fetchedObjects.count > 0) {
            // 若已有, 更新
            for (NSManagedObject *entity in fetchedObjects) {
                [userDataMeta setValue:[NSDate date] forKey:@"updateTime"];//创建更新时间
                BOOL ret = [userDataMeta setValuesForEntity:entity];
                if (!ret) {
#ifdef DEBUGMODE
                    LogError(@"[userDataManager::saveUserDataMeta()] update failed because of UserDataMeta::setValuesForEntity() error");
#endif
                    return NO;
                }
                
                NSError *error = nil;
                if (![context save:&error]) {
#ifdef DEBUGMODE
                    LogError(@"[userDataManager::saveUserDataMeta()] update failed when save to context, error: %@", [error localizedDescription]);
#endif
                    return NO;
                }
            }
            
            saved = YES;
        }
    }
    
    // 2. insert as new
    if (saved == NO) {
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"UserDataEntity" inManagedObjectContext:context];
        [userDataMeta setValue:[NSDate date] forKey:@"createTime"];//创建createTime
        BOOL ret = [userDataMeta setValuesForEntity:entity];
        if (!ret) {
#ifdef DEBUGMODE
            LogError(@"[userDataManager::saveUserDataMeta()] insert failed because of BookMarkMeta::setValuesForEntity() error");
#endif
            return NO;
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
#ifdef DEBUGMODE
            LogError(@"[userDataManager::saveUserDataMeta()] insert failed when save to context, error: %@", [error localizedDescription]);
#endif
            return NO;
        }
    }
    
    return YES;
    
    
}

#pragma mark - get user data
- (NSArray *)getUserDataWithDictionary:(NSDictionary *)keyDic andWithUserId:(NSString *)userId {
    NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];
    
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserDataEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //生成查询语句
    NSString *sqlString = [self generateSQLStringWithDictionary:keyDic andUserId:userId];
    
    
    // Predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@",sqlString];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects != nil &&
        fetchedObjects.count > 0) {
        for (NSManagedObject *entity in fetchedObjects) {
            
            //将entity转换成userDataMeta
            UserDataMeta *userDataMeta = nil;
            UserDataEntity *userDataEntity = (UserDataEntity *)entity;
            if (userDataEntity != nil) {
                userDataMeta = [UserDataMeta fromUserDataEntity:userDataEntity];
            }
            
            if (userDataMeta != nil) {
                [metaArray addObject:userDataMeta];
            }
            
        }
    }
    
    if (metaArray == nil || metaArray.count <= 0) {
        return nil;
    }
    return metaArray;
}




//生成查询条件
- (NSString *)generateSQLStringWithDictionary:(NSDictionary *)keydic andUserId:(NSString *)userId {
    
//    NSMutableString *sql = [[NSMutableString alloc] init];
    
//    NSString *userId = [NSUserDefaultUtil getUserId];//参数全部调用者传过来
    if (userId == nil || userId.length <= 0) {
        userId =@"";//防止userId = nil,导致程序崩掉
    }
    
    
    NSString *k1str = [self generateSQLStringWithArray:[keydic objectForKey:@"k1"] andKey:@"k1"];
    NSString *k2str = [self generateSQLStringWithArray:[keydic objectForKey:@"k2"] andKey:@"k2"];
    NSString *k3str = [self generateSQLStringWithArray:[keydic objectForKey:@"k3"] andKey:@"k3"];
    NSString *k4str = [self generateSQLStringWithArray:[keydic objectForKey:@"k4"] andKey:@"k4"];
    NSString *k5str = [self generateSQLStringWithArray:[keydic objectForKey:@"k5"] andKey:@"k5"];
    NSString *typeStr = [self generateSQLStringWithArray:[keydic objectForKey:@"type"] andKey:@"type"];
    
    NSString *sql = nil;
    //注：get时keyDic没有value键，delete时keyDic有“value”键，且对应的值是字符串。为了通用，做一次判断
    if ([keydic objectForKey:@"value"] == nil ) {//是在get方法中调用，需要判断是否会崩掉？？
        
        sql = [NSString stringWithFormat:@"(userId==%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)",userId,k1str,k2str,k3str,k4str,k5str,typeStr,[keydic objectForKey:@"value"]];
    }
    else {
        sql = [NSString stringWithFormat:@"(userId==%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)",userId,k1str,k2str,k3str,k4str,k5str,typeStr];
    }
    
    
#ifdef DEBUGMODE
    NSLog(@"sql语句是===%@",sql);
#endif
    if (sql == nil || sql.length <= 0) {
        return nil;
    }
    return sql;
    
}
//根据每个key对应的数组生成一个查询语句
- (NSString *)generateSQLStringWithArray:(NSArray *)keyArray andKey:(NSString *)key {
    NSMutableString *sqlString = [[NSMutableString alloc] init];
    for (NSString *tempString in keyArray) {
        if (tempString == nil) {
            continue;
        }
        NSString *str = [NSString stringWithFormat:@"%@=%@",key,tempString];
        [sqlString appendString:str];
        
    }
    return sqlString;
    
}


#pragma mark - delete userData
- (NSString *)deleteUserDataWithDictionary:(NSDictionary *)contentDic andWithUserId:(NSString *)userId {
    
    NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserDataEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Predicate  -- 生成查询条件
    NSString *formatString = [self generateSQLStringWithDictionary:contentDic andUserId:userId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || fetchedObjects.count <= 0) {
        return @"0"; // nothing to delete, return YES
    }
    //获得要删除的记录的条数
    NSString *amount = [NSString stringWithFormat:@"%ld",fetchedObjects.count];
    for (id entity in fetchedObjects) {
        [context deleteObject:entity];
    }
    
    if (![context save:&error]) {
        LogError(@"[UserDataMetaManager-deleteUserDataWithDictionary:andWithUserId:] failed when save to context, error: %@", [error localizedDescription]);
        return @"-1";
    }
    
    return amount;
}




@end
