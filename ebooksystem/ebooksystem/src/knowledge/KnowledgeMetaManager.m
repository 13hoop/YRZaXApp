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



@interface KnowledgeMetaManager ()


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

	// 1. save meta entity
	BOOL ret = [self saveKnowledgeMetaEntity:knowledgeMeta];
	if (!ret) {
		return ret;
	}

	// 2. save search entity
	ret = [self saveKnowledgeSearchEntity:knowledgeMeta];

	return ret;
}

// save knowledge meta as knowledge meta entity
- (BOOL)saveKnowledgeMetaEntity:(KnowledgeMeta *)knowledgeMeta {
	if (knowledgeMeta == nil) {
		return YES; // nothing to save, return YES
	}

	BOOL saved = NO;

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;
	// 1. try update if exists
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

		// Entity
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];

		// Predicate
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", knowledgeMeta.dataId, [NSNumber numberWithInteger:knowledgeMeta.dataType]];
		[fetchRequest setPredicate:predicate];

		NSError *error = nil;
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
		if (fetchedObjects != nil &&
		    fetchedObjects.count > 0) {
			// 若已有, 更新
			for (NSManagedObject *entity in fetchedObjects) {
				BOOL ret = [knowledgeMeta setValuesForEntity:entity];
				if (!ret) {
					LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] update failed because of knowledgeMeta::setValuesForEntity() error");
					return NO;
				}

//				NSError *error = nil;
//				if (![context save:&error]) {
//					LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] update failed when save to context, error: %@", [error localizedDescription]);
//					return NO;
//				}
			}

			[context performBlock: ^{
			    NSError *error = nil;
			    if (![context save:&error]) {
			        LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] update failed when save to context, error: %@", [error localizedDescription]);
//                return NO;
			        return;
				}
			}];

			saved = YES;
		}
	}

	// 2. insert as new
	if (saved == NO) {
		NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];

		BOOL ret = [knowledgeMeta setValuesForEntity:entity];
		if (!ret) {
			LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] insert failed because of knowledgeMeta::setValuesForEntity() error");
			return NO;
		}

		[context performBlock: ^{
		    NSError *error = nil;
		    if (![context save:&error]) {
		        LogError(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
//			return NO;
		        return;
			}
		}];
	}

	return YES;
}

// save knowledge meta as knowledge search entity
- (BOOL)saveKnowledgeSearchEntity:(KnowledgeMeta *)knowledgeMeta {
	if (knowledgeMeta == nil || knowledgeMeta.searchReverseInfo == nil || knowledgeMeta.searchReverseInfo.count <= 0) {
		return YES; // nothing to save, return YES
	}

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;

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
				NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeSearchEntity" inManagedObjectContext:context];
				[fetchRequest setEntity:entity];

				// Predicate
				NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchId==%@", knowledgeSearchReverseInfo.searchId];
				[fetchRequest setPredicate:predicate];

				NSError *error = nil;
				NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
				if (fetchedObjects != nil &&
				    fetchedObjects.count > 0) {
					// 若已有, 更新
					for (NSManagedObject *entity in fetchedObjects) {
//                        [entity setValue:knowledgeSearchReverseInfo.searchId forKey:@"searchId"];
						[entity setValue:knowledgeSearchResultItem.dataId forKey:@"dataId"];
						[entity setValue:knowledgeSearchResultItem.dataNameEn forKey:@"dataNameEn"];
						[entity setValue:knowledgeSearchResultItem.dataNameCh forKey:@"dataNameCh"];
					}

					[context performBlock: ^{
					    NSError *error = nil;
					    if (![context save:&error]) {
					        LogError(@"[KnowledgeMetaManager::saveKnowledgeSearchEntity()] update failed when save to context, error: %@", [error localizedDescription]);
					        //							return NO;
					        return;
						}
					}];

					saved = YES;
				}
			}

			// 2. insert as new
			if (saved == NO) {
				// create entity
				NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"KnowledgeSearchEntity" inManagedObjectContext:context];

				[entity setValue:knowledgeSearchReverseInfo.searchId forKey:@"searchId"];
				[entity setValue:knowledgeSearchResultItem.dataId forKey:@"dataId"];
				[entity setValue:knowledgeSearchResultItem.dataNameEn forKey:@"dataNameEn"];
				[entity setValue:knowledgeSearchResultItem.dataNameCh forKey:@"dataNameCh"];

				// save
				[context performBlock: ^{
				    NSError *error = nil;
				    if (![context save:&error]) {
				        LogError(@"[KnowledgeMetaManager::saveKnowledgeSearchEntity()] insert failed when save to context, error: %@", [error localizedDescription]);
//					return NO;
				        return;
					}
				}];
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

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;
	for (id entity in knowledgeMetaEntities) {
		[context deleteObject:entity];
	}

	[context performBlock: ^{
	    NSError *error = nil;
	    if (![context save:&error]) {
	        LogError(@"[KnowledgeMetaManager-deleteKnowledgeMetaWithDataId:andDataType:] failed when save to context, error: %@", [error localizedDescription]);
//		return NO;
	        return;
		}
	}];


	return YES;
}

//根据dataId删除数据库中的记录
- (BOOL)deleteKnowledgeMetaWithDataId:(NSString *)dataId {
	NSArray *knowledgeMetaEntities = [self getKnowledgeMetaWithDataId:dataId];
	if (knowledgeMetaEntities == nil || knowledgeMetaEntities.count <= 0) {
		return YES; // nothing to delete, return YES
	}

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;

	for (id entity in knowledgeMetaEntities) {
		if (entity == nil) {
			continue;
		}

		[context deleteObject:entity];
	}
//	NSError *error = nil;

//	if (![context save:&error]) {
//		LogError(@"[KnowledgeMetaManager-deleteKnowledgeMetaWithDataId:andDataType:] failed when save to context, error: %@", [error localizedDescription]);
//		return NO;
//	}


	// save
	[context performBlock: ^{
	    // do something that takes some time asynchronously using the temp context

	    // push to parent
	    NSError *error;
	    if (![context save:&error]) {
	        // handle error
	        LogError(@"[KnowledgeMetaManager-deleteKnowledgeMetaWithDataId:andDataType:] failed when save to context, error: %@", [error localizedDescription]);
	        return;  // return NO;
		}

	    // save parent to disk asynchronously
	    if ([NSThread isMainThread]) {
	        NSLog(@"在主线程中，保存context");
	        [[CoreDataUtil instance] saveContextWithWait:NO];
		}
	    else {
	        NSLog(@"回到主线程中保存context");
	        dispatch_sync(dispatch_get_main_queue(), ^{
				[[CoreDataUtil instance] saveContextWithWait:NO];
			});//回到主线程
		}
	}];

	return YES;
}

// clear knowledge metas
- (BOOL)clearKnowledgeMetas {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Fetch
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects != nil &&
	    fetchedObjects.count > 0) {
		for (NSManagedObject *entity in fetchedObjects) {
			[context deleteObject:entity];
		}
	}

	[context performBlock: ^{
        NSError *error = nil;
	    if (![context save:&error]) {
	        LogError(@"[KnowledgeMetaManager-clearKnowledgeMetas] failed when save to context, error: %@", [error localizedDescription]);
//		return NO;
	        return;
		}
	}];

	return YES;
}

#pragma mark - get knowledge meta


//get knowledge metas by dataType
//app启动时根据dataType来查询数据库，确定book_id对应的dataStatus是否处于未下载状态
- (NSArray *)getKnowledgeMetaWithDataType:(DataType)dataType {
	NSManagedObjectContext *context = [CoreDataUtil instance].managedObjectContext;

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataType=%@", dataType];
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

// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId {
	NSManagedObjectContext *context = [CoreDataUtil instance].managedObjectContext;

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@", dataId];
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

// get knowledge metas
- (NSArray *)getKnowledgeMetaWithDataId:(NSString *)dataId andDataType:(DataType)dataType {
	NSManagedObjectContext *context = [CoreDataUtil instance].managedObjectContext;

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];



//    NSPersistentStoreCoordinator *coordinator = [CoreDataUtil instance].persistentStoreCoordinator;

//    NSManagedObjectContext *managedObjectContext = [[CoreDataUtil instance]childThreadContext];
//    [managedObjectContext setPersistentStoreCoordinator:coordinator];

	//方法三：
//    NSManagedObjectContext *workContext = [[CoreDataUtil instance] generatePrivateContextWithParent:[CoreDataUtil instance].managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:workContext];

//最初的方法
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	//方法二：使用通知
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];

	// Predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
	[fetchRequest setPredicate:predicate];

	// Fetch
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	//方法三
//    NSArray *fetchedObjects = [workContext executeFetchRequest:fetchRequest error:&error];
//    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];




	/*
	   //1、关联NSmanagermodel对象。
	   NSManagedObjectModel *model=[NSManagedObjectModel mergedModelFromBundles:nil];//把左边栏中所有的model全都拷贝下来了。
	   //2、创建协调者。这句创建完成后：协调者就可以协调entity和model类
	   NSPersistentStoreCoordinator *coordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

	   NSString *path=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/core_data/ebooksystem.sqlite"];
	   NSURL *url=[NSURL fileURLWithPath:path];
	   [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:nil];
	   NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	   context.persistentStoreCoordinator = coordinator;
	   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"KnowledgeMetaEntity"];
	   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
	   [fetchRequest setPredicate:predicate];
	   NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];

	 */

	/*
	   //切换回主线程，保存context
	   if ([NSThread isMainThread]) {
	    NSLog(@"在主线程中，保存context");
	    [[CoreDataUtil instance] saveContextWithWait:NO];
	   }
	   else {
	    NSLog(@"回到主线程中保存context");
	    //        [self performSelectorOnMainThread:@selector(handleResult) withObject:nil waitUntilDone:YES];
	    dispatch_sync(dispatch_get_main_queue(), ^{
	        [[CoreDataUtil instance]saveContextWithWait:NO];
	    });//回到主线程

	   }
	 */

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

- (void)handleResult {
	[[CoreDataUtil instance] saveContextWithWait:NO];
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
	NSString *dataCurVersion = @"";// nil;
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
	NSManagedObjectContext *context = [CoreDataUtil instance].managedObjectContext;

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate  -----根据dataId和dataStatus获取knowledgeMetas
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataStatus=%@", dataId, [NSNumber numberWithInteger:dataStatus]];
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

//  2.0 get knowledge meta according to bookCategory
- (NSArray *)getKnowledgeMetaWithBookCategory:(NSString *)bookCategory {
	NSManagedObjectContext *context = [CoreDataUtil instance].managedObjectContext;

	NSMutableArray *metaArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate  -----根据bookcategory来构造查询条件,查询条件
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookCategory=%@", bookCategory];
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

#pragma mark - setter
// 更新数据的状态及状态描述
- (BOOL)setDataStatusTo:(DataStatus)status andDataStatusDescTo:(NSString *)desc forDataWithDataId:(NSString *)dataId andType:(DataType)dataType {
	if (dataId == nil) {
		return YES; // nothing to save, return YES
	}

	BOOL saved = NO;

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;
	// 1. try update if exists
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

		// Entity
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];

		// Predicate
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
		[fetchRequest setPredicate:predicate];

		NSError *error = nil;
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
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


				// save
				[context performBlock: ^{
				    NSError *error = nil;
				    if (![context save:&error]) {
				        LogError(@"[KnowledgeMetaManager-setDataStatusTo:andDataStatusDescTo:forDataWithDataId:andType:] update failed when save to context, error: %@", [error localizedDescription]);
//					return NO;
				        return;
					}
				}];
			}

			saved = YES;
		}
	}
	// 2. insert as new if not exists
	if (saved == NO) {
		KnowledgeMeta *knowledgeMeta = [[KnowledgeMeta alloc] init];
		[knowledgeMeta setDataId:dataId];
		[knowledgeMeta setDataType:dataType];
		[knowledgeMeta setDataStatus:status];
		[knowledgeMeta setDataStatusDesc:desc];

		[self saveKnowledgeMeta:knowledgeMeta];
	}

	//保存save
	//切换至主线程，保存context
	if ([NSThread isMainThread]) {
//		NSLog(@"在主线程中，保存context");
		[[CoreDataUtil instance] saveContextWithWait:NO];
	}
	else {
//		NSLog(@"回到主线程中保存context");
//        [self performSelectorOnMainThread:@selector(handleResult) withObject:nil waitUntilDone:YES];
		dispatch_sync(dispatch_get_main_queue(), ^{
			[[CoreDataUtil instance] saveContextWithWait:NO];
		});        //回到主线程
	}

	return saved;
}

// get searchable knowledge metas
- (NSArray *)getSearchableKnowledgeMetas {
	NSManagedObjectContext *context = [CoreDataUtil instance].managedObjectContext;

	NSMutableArray *knowledgeMetas = [[NSMutableArray alloc] init];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataSearchType==%d", DATA_SEARCH_SEARCHABLE];
	[fetchRequest setPredicate:predicate];

	// Fetch
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
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

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;
	// 1. try update if exists
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

		// Entity
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];

		// Predicate
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataId==%@ and dataType=%@", dataId, [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
		[fetchRequest setPredicate:predicate];

		NSError *error = nil;
		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

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

				[context performBlock: ^{
				    NSError *error = nil;
				    if (![context save:&error]) {
				        LogError(@"[KnowledgeMetaManager-setDataStatusTo:andDataStatusDescTo:forDataWithDataId:andType:] update failed when save to context, error: %@", [error localizedDescription]);
//					return NO;
				        return;
					}
				}];
			}

			saved = YES;
		}
	}


	//保存save
	//切换会主线程，保存context
	if ([NSThread isMainThread]) {
		NSLog(@"在主线程中，保存context");
		[[CoreDataUtil instance] saveContextWithWait:NO];
	}
	else {
		NSLog(@"回到主线程中保存context");
//        [self performSelectorOnMainThread:@selector(handleResult) withObject:nil waitUntilDone:YES];
		dispatch_sync(dispatch_get_main_queue(), ^{
			[[CoreDataUtil instance] saveContextWithWait:NO];
		});        //回到主线程
	}




	return saved;
}

//检查数据的状态和数据的下载进度，修改数据的状态
- (BOOL)setDataStatusforDataWithDataType:(DataType)dataType {
	BOOL saved = NO;

	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;
	// 1. try update if exists
	{
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

		// Entity
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:context];
		[fetchRequest setEntity:entity];

		// Predicate
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataType=%@", [NSNumber numberWithInteger:DATA_TYPE_DATA_SOURCE]];
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
				NSString *progress = [entity valueForKey:@"dataStatusDesc"];
				NSNumber *curDataStatusNum = [entity valueForKey:@"dataStatus"];
				int curDataStatus = [curDataStatusNum intValue];
				LogInfo(@"curDataStatus===========================%d", curDataStatus);
				if ([progress isEqualToString:@"100"] == NO && curDataStatus != 10) {
					//dataStatus不等于DATA_STATUS_UPDATE_COMPLETED（10），progress不等于100，则设置为下载暂停的状态

//                    [entity setValue:[NSNumber numberWithInteger:DATA_STATUS_DOWNLOAD_PAUSE] forKey:@"dataStatus"];
					[entity setValue:[NSNumber numberWithInteger:DATA_STATUS_DOWNLOAD_FAILED] forKey:@"dataStatus"];
				}
				//save
				if (![context save:&error]) {
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
