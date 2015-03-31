//
//  CollectionMetaManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/8.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "CollectionMetaManager.h"
#import "CoreDataUtil.h"
#import "LogUtil.h"


@implementation CollectionMetaManager

#pragma mark - singleton单例
+ (CollectionMetaManager *)instance {
	static CollectionMetaManager *sharedInstance = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		sharedInstance = [[CollectionMetaManager alloc] init];
	});

	return sharedInstance;
}

#pragma mark - save and load meta info

- (BOOL)saveCollectionMeta:(CollectionMeta *)collectMeta {
	if (collectMeta == nil) {
		return NO;
	}

	BOOL saved = NO;

	NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];
	// 1. try update if exists
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

		// Entity
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"CollectionEntity" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];

		// Predicate
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and contentQueryId=%@", collectMeta.bookId, collectMeta.contentQueryId];
		[fetchRequest setPredicate:predicate];

		NSError *error = nil;
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
		if (fetchedObjects != nil &&
		    fetchedObjects.count > 0) {
			// 若已有, 更新
			for (NSManagedObject *entity in fetchedObjects) {
				BOOL ret = [collectMeta setValuesForEntity:entity];
				if (!ret) {
					LogError(@"[CollectionMetaManager::saveCollectionMeta()] update failed because of CollectionMetaManager::setValuesForEntity() error");
					return NO;
				}

				NSError *error = nil;
				if (![context save:&error]) {
					LogError(@"[CollectionMetaManager::saveCollectionEntity()] update failed when save to context, error: %@", [error localizedDescription]);
					return NO;
				}
			}

			saved = YES;
		}
	}

	// 2. insert as new
	if (saved == NO) {
		NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"CollectionEntity" inManagedObjectContext:context];

		BOOL ret = [collectMeta setValuesForEntity:entity];
		if (!ret) {
			LogError(@"[CollectionMetaManager::saveCollectionEntity()] insert failed because of collectionMeta::setValuesForEntity() error");
			return NO;
		}

		NSError *error = nil;
		if (![context save:&error]) {
			LogError(@"[CollectionMetaManager::saveCollectionEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
			return NO;
		}
	}

	return YES;
}

#pragma mark - getter

//根据参数构造不同的查询条件
- (NSPredicate *)generatePresdicateWithBookId:(NSString *)bookId andWithCollectionType:(NSString *)collectionType andWithQueryId:(NSString *)queryId {
	if (bookId != nil && bookId.length > 0) {//bookId不为空
		if (collectionType == nil || collectionType.length <= 0) {//collectionType为空
			if (queryId == nil || queryId.length <= 0) {//queryId为空
				//collectionType = queryId = nil ,bookId 不为空
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId=%@", bookId];
				return predicate;
			}
			else {
				//collectionType = nil ,bookId , queryId 不为空
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and contentQueryId=%@", bookId, queryId];
				return predicate;
			}
		}
		else {//collectionType不为空
			if (queryId == nil || queryId.length <= 0) {//queryId为空
				//  queryId = nil , bookId ,collectionType 不为空
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and collectionType=%@", bookId, collectionType];
				return predicate;
			}
			else {
				//collectionType  ,bookId , queryId 不为空
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and contentQueryId=%@ and collectionType=%@", bookId, queryId, collectionType];
				return predicate;
			}
		}
	}
	else {
		return nil;
	}
}

//根据bookId , collectionType ,queryId来查询数据库,三者都有可能为空，需要根据不同参数来构造不同的查询条件
- (NSArray *)getCollectionMetaWith:(NSString *)bookId andcollectionType:(NSString *)collectionType andQueryId:(NSString *)queryId {
	NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CollectionEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate
	//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and bookMarkType=%@ and targetId=%@", bookId, bookMarkType,queryId];
	NSPredicate *predicate = [self generatePresdicateWithBookId:bookId andWithCollectionType:collectionType andWithQueryId:queryId];
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

//查询所有书签
- (NSArray *)getAllCollectionMeta {
	NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CollectionEntity" inManagedObjectContext:context];
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

//根据bookId , queryId获取collectionMeta信息
- (NSArray *)getCollectionMetaWith:(NSString *)bookId andQueryId:(NSString *)queryId {
	NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"CollectionEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookId==%@ and contentQueryId=%@", bookId, queryId];
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

#pragma mark - remove

//根据bookId , queryId 删除collectionMeta
- (BOOL)deleteCollectionMetaWithBookId:(NSString *)bookId andWithQueryId:(NSString *)queryId {
	NSArray *collectionMetaEntities = [self getCollectionMetaWith:bookId andQueryId:queryId];
	if (collectionMetaEntities == nil || collectionMetaEntities.count <= 0) {
		return YES; // nothing to delete, return YES
	}

	NSManagedObjectContext *context = [[CoreDataUtil instance] temporaryContext];

	for (id entity in collectionMetaEntities) {
		[context deleteObject:entity];
	}

	NSError *error = nil;
	if (![context save:&error]) {
		LogError(@"[collectionMetaManager-deleteCollectionMetaWithBookId:andCollectionMarkId:] failed when save to context, error: %@", [error localizedDescription]);
		return NO;
	}

	return YES;
}

@end
