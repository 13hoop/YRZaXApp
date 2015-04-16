//
//  CollectionMetaManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionMeta.h"


@interface CollectionMetaManager : NSObject


#pragma mark - singleton单例
+ (CollectionMetaManager *)instance;

#pragma mark - save && add collection
//保存JS传来的collection信息
- (BOOL)saveCollectionMeta:(CollectionMeta *)collectMeta;

#pragma mark - getter

//根据bookId , collectionType ,queryId来查询数据库,三者都有可能为空，需要根据不同参数来构造不同的查询条件
- (NSArray *)getCollectionMetaWith:(NSString *)bookId andcollectionType:(NSString *)collectionType andQueryId:(NSString *)queryId;

//获取数据库中所有的collectionMeta信息
- (NSArray *)getAllCollectionMeta;


#pragma mark - remove


- (BOOL)deleteCollectionMetaWithBookId:(NSString *)bookId andWithQueryId:(NSString *)queryId;

@end
