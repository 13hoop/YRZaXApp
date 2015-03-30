//
//  KnowledgeSearchManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/8/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeSearchManager.h"
#import "CoreDataUtil.h"



@implementation KnowledgeSearchManager

#pragma mark - singleton
+ (KnowledgeSearchManager *)instance {
	static KnowledgeSearchManager *sharedInstance = nil;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		if (sharedInstance == nil) {
		    sharedInstance = [[KnowledgeSearchManager alloc] init];
		}
	});

	return sharedInstance;
}

#pragma mark - search
// search data
- (NSArray *)searchData:(NSString *)searchId {
	NSManagedObjectContext *context = [CoreDataUtil instance].temporaryContext;

	NSMutableArray *searchArray = [[NSMutableArray alloc] init];


	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	// Entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"KnowledgeSearchEntity" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	// Predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchId==%@", searchId];
	[fetchRequest setPredicate:predicate];

	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects != nil &&
	    fetchedObjects.count > 0) {
		for (NSManagedObject *entity in fetchedObjects) {
			[searchArray addObject:entity];
		}
	}

	if (searchArray == nil || searchArray.count <= 0) {
		return nil;
	}
	return searchArray;
}

@end
