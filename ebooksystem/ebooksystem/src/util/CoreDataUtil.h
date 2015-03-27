//
//  CoreDataUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/7/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataUtil : NSObject

#pragma mark - properties

@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (readonly ,nonatomic, strong) NSManagedObjectContext *childThreadManagedObjectContext;
@property (readonly, nonatomic, strong) NSEntityDescription *pChildThreadEntityDec;


#pragma mark - methods

#pragma mark - singleton
// singleton
+ (CoreDataUtil *)instance;

- (void)saveContext;


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (NSManagedObjectContext*) childThreadContext;

@end
