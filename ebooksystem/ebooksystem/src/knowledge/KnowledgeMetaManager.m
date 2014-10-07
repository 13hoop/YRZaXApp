//
//  KnowledgeMetaManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/7/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeMetaManager.h"
#import "KnowledgeMeta.h"
#import "KnowledgeSearchReverseInfo.h"
#import "CoreDataUtil.h"



@interface KnowledgeMetaManager()


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
        NSLog(@"[KnowledgeMetaManager::loadKnowledgeMeta()]failed, file: %@, error: %@", fullFilePath, error.localizedDescription);
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
    
    BOOL ret = [self saveKnowledgeMetaEntity:knowledgeMeta];
    if (!ret) {
        return ret;
    }
    
    ret = [self saveKnowledgeSearchEntity:knowledgeMeta];
    
    return ret;
}

// save knowledge meta as knowledge meta entity
- (BOOL)saveKnowledgeMetaEntity:(KnowledgeMeta *)knowledgeMeta {
    if (knowledgeMeta == nil) {
        return YES; // nothing to save, return YES
    }
    
    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"KnowledgeMetaEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
    
    BOOL ret = [knowledgeMeta setValuesForEntity:entity];
    if (!ret) {
        NSLog(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] failed because of knowledgeMeta::setValuesForEntity() error");
        return NO;
    }
    
    NSError *error = nil;
    if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
        NSLog(@"[KnowledgeMetaManager::saveKnowledgeMetaEntity()] failed to save to context, error: %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

// save knowledge meta as knowledge search entity
- (BOOL)saveKnowledgeSearchEntity:(KnowledgeMeta *)knowledgeMeta {
    if (knowledgeMeta == nil || knowledgeMeta.searchReverseInfo == nil || knowledgeMeta.searchReverseInfo.count <= 0) {
        return YES; // nothing to save, return YES
    }
    
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
            
            // create entity
            NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:@"KnowledgeSearchEntity" inManagedObjectContext:[CoreDataUtil instance].managedObjectContext];
            
            [entity setValue:knowledgeSearchReverseInfo.searchId forKey:@"searchId"];
            [entity setValue:knowledgeSearchResultItem.dataId forKey:@"dataId"];
            [entity setValue:knowledgeSearchResultItem.dataNameEn forKey:@"dataNameEn"];
            [entity setValue:knowledgeSearchResultItem.dataNameCh forKey:@"dataNameCh"];
            
            // save
            if (![[CoreDataUtil instance].managedObjectContext save:&error]) {
                NSLog(@"[KnowledgeMetaManager::saveKnowledgeSearchEntity()] failed to save to context, error: %@", [error localizedDescription]);
                return NO;
            }
        }
    }
    
    return YES;
}


@end