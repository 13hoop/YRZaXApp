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
@property (readonly,nonatomic, strong) NSManagedObjectContext *backgroundObjectContext;
@property (readonly,nonatomic, strong) NSManagedObjectContext *temporaryContext;

//创建recordDataContext
@property (readonly,nonatomic, strong) NSManagedObjectContext *recordDataContext;



#pragma mark - methods

#pragma mark - singleton
// singleton
+ (CoreDataUtil *)instance;

- (void)saveContext;


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (NSManagedObjectContext *) childThreadContext;
- (NSManagedObjectContext *) backgroundContext;
//- (NSManagedObjectContext *) temporaryContext;

//创建工作context
- (NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext;

//保存 context的变化
- (void)saveContextWithWait:(BOOL)needWait;

@end
