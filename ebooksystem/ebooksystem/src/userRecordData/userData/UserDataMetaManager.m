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
        
        
        NSString *sqlString = [self generateGetUserDataSqlStringWithUserDataMeta:userDataMeta];
        // Predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:sqlString];
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


//生成getUserData的sql语句
- (NSString *)generateGetUserDataSqlStringWithUserDataMeta:(UserDataMeta *)userDateMeta {
    if (userDateMeta == nil) {
        return nil;
    }
    NSMutableString *sqlString = [[NSMutableString alloc] init];
    
    //userId
    if (userDateMeta.userId == nil) {
        NSString *userId = @"defaultUserId";
        NSString *userIdSql = [NSString stringWithFormat:@"(userId='%@')",userId];
        [sqlString appendString:userIdSql];
    }
    else {
        NSString *userIdSql = [NSString stringWithFormat:@"(userId='%@')",userDateMeta.userId];
        [sqlString appendString:userIdSql];
    }
    //k1 : '', k2 : '', k3 : '', k4 : '', k5 : '', type : ''
    //k1
    if (userDateMeta.k1 != nil && userDateMeta.k1.length > 0) {
        NSString *k1Sql = [NSString stringWithFormat:@" AND(k1='%@')",userDateMeta.k1];
        [sqlString appendString:k1Sql];
    }
    //k2
    if (userDateMeta.k2 != nil && userDateMeta.k2.length > 0) {
        NSString *k2Sql = [NSString stringWithFormat:@" AND(k2='%@')",userDateMeta.k2];
        [sqlString appendString:k2Sql];
    }
    //k3
    if (userDateMeta.k3 != nil && userDateMeta.k3.length > 0) {
        NSString *k3Sql = [NSString stringWithFormat:@" AND(k3='%@')",userDateMeta.k3];
        [sqlString appendString:k3Sql];
    }
    //k4
    if (userDateMeta.k4 != nil && userDateMeta.k4.length > 0) {
        NSString *k4Sql = [NSString stringWithFormat:@" AND(k4='%@')",userDateMeta.k4];
        [sqlString appendString:k4Sql];
    }
    //k5
    if (userDateMeta.k5 != nil && userDateMeta.k5.length > 0) {
        NSString *k5Sql = [NSString stringWithFormat:@" AND(k5='%@')",userDateMeta.k5];
        [sqlString appendString:k5Sql];
        
    }
    //type
    if (userDateMeta.type != nil && userDateMeta.type.length > 0) {
        NSString *typeSql = [NSString stringWithFormat:@" AND(type='%@')",userDateMeta.type];
        [sqlString appendString:typeSql];
    }
    
    if (sqlString == nil || sqlString.length <= 0 ) {
        return nil;
    }
    return sqlString;
    
    
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
    //切记：%@不是predicate的formate，它是string的formate
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@",sqlString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:sqlString];
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
        userId =@"defaultUserId";//防止userId = nil,导致程序崩掉
    }
    
    //每个arg对应一个dic，dic中的内容可能有些“键值对”是不存在的。
    
    
    NSString *k1str = [self generateSQLStringWithArray:[keydic objectForKey:@"k1"] andKey:@"k1"];
    NSString *k2str = [self generateSQLStringWithArray:[keydic objectForKey:@"k2"] andKey:@"k2"];
    NSString *k3str = [self generateSQLStringWithArray:[keydic objectForKey:@"k3"] andKey:@"k3"];
    NSString *k4str = [self generateSQLStringWithArray:[keydic objectForKey:@"k4"] andKey:@"k4"];
    NSString *k5str = [self generateSQLStringWithArray:[keydic objectForKey:@"k5"] andKey:@"k5"];
    NSString *typeStr = [self generateSQLStringWithArray:[keydic objectForKey:@"type"] andKey:@"type"];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    //注：get时keyDic没有"value"键，delete时keyDic有“value”键，且对应的值是字符串。为了通用，做一次判断
    if ([keydic objectForKey:@"value"] == nil ) {//是在get方法中调用，需要判断是否会崩掉？？
        NSString *userIdSql = [NSString stringWithFormat:@"(userId='%@')",userId];
        [sql appendString:userIdSql];
        if (k1str != nil && k1str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k1str];
            [sql appendString:tempSql];
        }
        if (k2str != nil && k2str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k2str];
            [sql appendString:tempSql];
        }
        if (k3str != nil && k3str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k3str];
            [sql appendString:tempSql];
        }
        if (k4str != nil && k4str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k4str];
            [sql appendString:tempSql];
        }
        if (k5str != nil && k5str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k5str];
            [sql appendString:tempSql];
        }
        if (typeStr != nil && typeStr.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",typeStr];
            [sql appendString:tempSql];
        }
        
        
        
        
    }
    else {
        
//        sql = [NSString stringWithFormat:@"(userId==%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)AND(%@)",userId,k1str,k2str,k3str,k4str,k5str,typeStr,[keydic objectForKey:@"value"]];
        
        NSString *userIdSql = [NSString stringWithFormat:@"(userId='%@')",userId];
        [sql appendString:userIdSql];
        
        if (k1str != nil && k1str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k1str];
            [sql appendString:tempSql];
        }
        if (k2str != nil && k2str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k2str];
            [sql appendString:tempSql];
        }
        if (k3str != nil && k3str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k3str];
            [sql appendString:tempSql];
        }
        if (k4str != nil && k4str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k4str];
            [sql appendString:tempSql];
        }
        if (k5str != nil && k5str.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",k5str];
            [sql appendString:tempSql];
        }
        if (typeStr != nil && typeStr.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",typeStr];
            [sql appendString:tempSql];
        }
        NSString *tempSql = [NSString stringWithFormat:@" AND(%@)",[keydic objectForKey:@"value"]];
        [sql appendString:tempSql];

    }
    
    
#ifdef DEBUGMODE
    NSLog(@"sql语句是===%@",sql);
#endif
    if (sql == nil || sql.length <= 0) {
        return nil;
    }
    return sql;
    
}
//根据每个key对应的数组生成一个查询语句,数组中每个元素是一个字典
- (NSString *)generateSQLStringWithArray:(NSArray *)keyArray andKey:(NSString *)key {
    NSMutableString *sqlString = [[NSMutableString alloc] init];
    
    //{ arg1 : { k1:[], k2:[] ... type : [] }, arg2 : { 同 @getUserData } }
    //k1 ,k2 ,k3 ...对应的键值对，可能会不存在。所以需要判断是否存在，若是不存在，则跳过
    
    if (keyArray == nil || keyArray.count <= 0) {
        return nil;
    }
    
    for (NSUInteger i = 0; i<keyArray.count; i++) {
        NSString *tempString = keyArray[i];
        if ( tempString == nil || tempString.length <= 0 ) {
            continue;
        }
        NSString *str = nil;
        if (keyArray.count > 1) {
            str = [NSString stringWithFormat:@"(%@='%@')",key,tempString];
        }
        else {
            str = [NSString stringWithFormat:@"%@='%@'",key,tempString];
        }
        [sqlString appendString:str];
        if (i < keyArray.count - 1) {
            [sqlString appendString:@" OR"];
        }
        
        
    }
    
    return sqlString;
    
}

//生成delete时用的sql语句
- (NSString *)generateDeleteSQLStringWithDictionary:(NSDictionary *)dic andUserId:(NSString *)userId {
    
    NSMutableString *sqlString = [[NSMutableString alloc] init];
    
    if (userId == nil || userId.length <= 0) {
        userId = @"defaultUserId";
    }
    NSString *tempUserId = [NSString stringWithFormat:@"(userId='%@') AND",userId];
    [sqlString appendString:tempUserId];
    
    NSArray *keyArray = [dic allKeys];
    for (NSUInteger i = 0; i<keyArray.count; i++) {
        NSString *tempKey = keyArray[i];
        if ( tempKey == nil || tempKey.length <= 0 ) {
            continue;
        }
        NSString *tempString = [NSString stringWithFormat:@"(%@='%@')",tempKey,[dic objectForKey:tempKey]];
        [sqlString appendString:tempString];
        
        if (i < keyArray.count - 1) {
            [sqlString appendString:@" AND"];
        }
        
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
    NSString *formatString = [self generateDeleteSQLStringWithDictionary:contentDic andUserId:userId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];
    [fetchRequest setPredicate:predicate];
    
    // Fetch
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || fetchedObjects.count <= 0) {
        return @"0"; // nothing to delete, return YES
    }
    //获得要删除的记录的条数
    NSString *amount = [NSString stringWithFormat:@"%ld",(unsigned long)fetchedObjects.count];
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
