//
//  CoreDataUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/7/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "CoreDataUtil.h"
#import "PathUtil.h"
#import "LogUtil.h"



@interface CoreDataUtil()

#pragma mark - properties
@property (readonly, nonatomic, strong) NSURL *coreDataStoreUrl;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly,nonatomic, strong) NSManagedObjectContext *backgroundObjectContext;


#pragma mark - methods
- (NSURL *)applicationDocumentsDirectory;

@end




@implementation CoreDataUtil

@synthesize coreDataStoreUrl = _coreDataStoreUrl;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize backgroundObjectContext = _backgroundObjectContext;
@synthesize temporaryContext = _temporaryContext;

#pragma mark - properties
- (NSURL *)coreDataStoreUrl {
    if (_coreDataStoreUrl == nil) {
        NSString *coreDataRootDir = @"core_data";
        NSString *coreDataFilename = @"ebooksystem.sqlite";
        
        NSURL *coreDataRootUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", coreDataRootDir]];
        NSString *coreDataRootPath = [coreDataRootUrl absoluteString];
        
        NSError *error = nil;
        BOOL isDir = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:coreDataRootPath isDirectory:&isDir];
        if (exists == NO) {
            [[NSFileManager defaultManager] createDirectoryAtURL:coreDataRootUrl withIntermediateDirectories:YES attributes:nil error:&error];
        }
        _coreDataStoreUrl = [coreDataRootUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", coreDataFilename]];
    }
    
    return _coreDataStoreUrl;
}

#pragma mark - singleton

+ (CoreDataUtil *)instance {
    static CoreDataUtil *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - core data operation

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            LogError(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        }
    }
}

#pragma mark - test multi thread \ core data
//- (NSManagedObjectContext*) childThreadContext
//{
////    [self managedObjectContext];
//    if (_childThreadManagedObjectContext != nil)
//    {
//        return _childThreadManagedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil)
//    {
//        _childThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_childThreadManagedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    else
//    {
//        NSLog(@"create child thread managed object context failed!");
//    }
//    
//    [_childThreadManagedObjectContext setStalenessInterval:0.0];
//    [_childThreadManagedObjectContext setMergePolicy:NSOverwriteMergePolicy];
//    
//    //////init entity description.
//    _pChildThreadEntityDec = [NSEntityDescription entityForName:@"KnowledgeMetaEntity" inManagedObjectContext:_childThreadManagedObjectContext];
//    if (_pChildThreadEntityDec == nil)
//    {
//        NSLog(@"error init entity description!");
//    }
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextChangesForNotification:) name:NSManagedObjectContextDidSaveNotification object:_childThreadManagedObjectContext];
//    
//    return _childThreadManagedObjectContext;
//}

//- (void)mergeOnMainThread:(NSNotification *)aNotification
//{
//    [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:aNotification];
//}
//
//- (void)mergeContextChangesForNotification:(NSNotification *)aNotification
//{
//    [self performSelectorOnMainThread:@selector(mergeOnMainThread:) withObject:aNotification waitUntilDone:YES];
//}







#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        // create main thread MOC
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = [self backgroundContext];
    }
    return _managedObjectContext;
}



- (NSManagedObjectContext*) backgroundContext {
    if(!_backgroundObjectContext){
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        _backgroundObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _backgroundObjectContext;
}

- (NSManagedObjectContext *) temporaryContext {
    _temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _temporaryContext.parentContext = [self managedObjectContext];
    
    return _temporaryContext;
}

////生成工作线程
//- (NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext {
//    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    privateContext.parentContext = parentContext;
//    return privateContext;
//}

//save context 变化
- (void)saveContextWithWait:(BOOL)needWait
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObjectContext *rootObjectContext = [self backgroundObjectContext];
    
    if (nil == managedObjectContext) {
        return;
    }
    if ([managedObjectContext hasChanges]) {
        NSLog(@"Main context need to save");
//        [managedObjectContext performBlock:^{
            [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Save main context failed and error is %@", error);
            }
        }];
    }
    
    if (nil == rootObjectContext) {
        return;
    }
    
    if ([rootObjectContext hasChanges]) {
        NSLog(@"Root context need to save");
        if (needWait) {
            [managedObjectContext performBlockAndWait:^{
                NSError *saveRootError = nil;
                if (![rootObjectContext save:&saveRootError]) {
                    NSLog(@"save rootObjectRoot failed ,error=====%@",saveRootError.localizedDescription);
                }
            }];
        }
        else {
            NSError *saveRootError = nil;
            if (![rootObjectContext save:&saveRootError]) {
                NSLog(@"save rootObjectRoot failed ,error=====%@",saveRootError.localizedDescription);
            }
        }
    }
}





// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ebooksystem" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Add this block of code.  Basically, it forces all threads that reach this
    // code to be processed in an ordered manner on the main thread.  The first
    // one will initialize the data, and the rest will just return with that
    // data.  However, it ensures the creation is not attempted multiple times.
    if (![NSThread currentThread].isMainThread) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            (void)[self persistentStoreCoordinator];
        });
        return _persistentStoreCoordinator;
    }
    
    // construct
    NSURL *storeURL = self.coreDataStoreUrl;
    LogInfo(@"[CoreDataUtil::persistentStoreCoordinator] Store url is %@", storeURL);
    
    // 设置选项, 支持data model version
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        LogError(@"[CoreDataUtil::persistentStoreCoordinator] Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
