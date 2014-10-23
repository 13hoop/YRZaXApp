//
//  KnowledgeDataLoader.m
//  ebooksystem
//
//  Created by zhenghao on 10/21/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataLoader.h"

#import "Config.h"

#import "LogUtil.h"


#include <stdio.h>



// index文件中, 每行的最大长度, B
#define MAX_LINE_LENGTH 1024



// knowledge data index
@interface KnowledgeDataIndex : NSObject

// 数据文件名
@property (nonatomic, copy) NSString *dataFilename;
// 数据在数据文件中的offset
@property (nonatomic, assign) NSInteger offset;
// 数据在数据文件中的len
@property (nonatomic, assign) NSInteger len;

// 此index的上一次使用时间
@property (nonatomic, copy) NSDate *lastUsedTime;

@end


//// knowledge query item
//@interface KnowledgeQueryItem : NSObject
//
//// query id
//@property (nonatomic, copy) NSString *queryId;
//// knowledge data index
//@property (nonatomic, copy) KnowledgeDataIndex *index;
//
//@end


// knowledge data loader
@interface KnowledgeDataLoader()

#pragma mark - properties
// knowledge data map
// <data_id, <query_id, {data_file_name, offset, len, last_used_time}>>
@property (nonatomic, retain) NSMapTable *knowledgeDataMap;

#pragma mark - load knowledge data
// 根据knowledgeDataIndex, 加载knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeDataIndex *)dataIndex;

#pragma mark - load knowledge index file
// 加载index文件
- (BOOL)loadKnowledgeIndex:(NSString *)indexFilename;


@end



@implementation KnowledgeDataIndex

@synthesize dataFilename;
@synthesize offset;
@synthesize len;
@synthesize lastUsedTime;

@end


//@implementation KnowledgeQueryItem
//
//@synthesize queryId;
//@synthesize index;
//
//@end



@implementation KnowledgeDataLoader

@synthesize knowledgeDataMap = _knowledgeDataMap;



#pragma mark - properties
- (NSMapTable *)knowledgeDataMap {
    if (_knowledgeDataMap == nil) {
        _knowledgeDataMap = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    }
    
    return _knowledgeDataMap;
}


#pragma mark - singleton
+ (KnowledgeDataLoader *)instance {
    static KnowledgeDataLoader *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[KnowledgeDataLoader alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - load knowledge data
// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSString *)getKnowledgeDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename {
    id obj = [self.knowledgeDataMap objectForKey:dataId];
    if (obj == nil) {
        // try load the index file
        BOOL ret = [self loadKnowledgeIndex:indexFilename forData:dataId];
        if (!ret) {
            LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since fail to load index from file: %@", indexFilename);
            return nil;
        }
        
        // get query map
        obj = [self.knowledgeDataMap objectForKey:dataId];
        if (obj == nil) {
            LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since no query map for query id: %@, even after loading index file: %@", queryId, indexFilename);
            return nil;
        }
    }
    
    // <query_id, {data_file_name, offset, len, last_used_time}>
    NSMapTable *queryMap = (NSMapTable *)obj;
    if (queryMap == nil) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since no query map for query id: %@", queryId);
        return nil;
    }
    
    id queryObj = [queryMap objectForKey:queryId];
    if (queryObj == nil) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since query obj is nil for query id: %@", queryId);
        return nil;
    }
    
    KnowledgeDataIndex *dataIndex = (KnowledgeDataIndex *)queryObj;
    if (dataIndex == nil) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since data index is nil for query id: %@", queryId);
        return nil;
    }
    
    return [self loadKnowledgeData:dataIndex];
}

// 根据knowledgeDataIndex, 加载knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeDataIndex *)dataIndex {
    NSString *data = nil;
    
    {
        char buffer[dataIndex.len];
        
        NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
        
        NSString *dataFilename = [NSString stringWithFormat:@"%@/%@/%@", knowledgeDataRootPathInApp, @"kaoyan^book_index_data^english#english_realexam_2010", dataIndex.dataFilename];
        
        FILE *fp = fopen([dataFilename UTF8String], "r");
        fseek(fp, dataIndex.offset, SEEK_SET);
        
        fread(buffer, dataIndex.len, sizeof(char), fp);
        data = [NSString stringWithUTF8String:buffer];
        
        fclose(fp);
    }
    
    return data;
}

#pragma mark - load knowledge index file
// 加载index文件
- (BOOL)loadKnowledgeIndex:(NSString *)indexFilename forData:(NSString *)dataId {
    FILE *fp = fopen([indexFilename UTF8String], "r");
    if (fp == NULL) {
        return NO;
    }
    
    char buffer[MAX_LINE_LENGTH];
    while (fgets(buffer, MAX_LINE_LENGTH, fp) != NULL) {
        NSString *line = [NSString stringWithUTF8String:buffer];
        NSArray *fields = [line componentsSeparatedByString:@"\t"];
        if (fields == nil || fields.count < 4) {
            continue;
        }
        
        NSString *queryId = [fields objectAtIndex:0];
        NSString *dataFilename = [fields objectAtIndex:1];
        NSInteger offset = [[fields objectAtIndex:2] integerValue];
        NSInteger len = [[fields objectAtIndex:3] integerValue];
        
        KnowledgeDataIndex *index = [[KnowledgeDataIndex alloc] init];
        index.dataFilename = dataFilename;
        index.offset = offset;
        index.len = len;
        
        // 添加到knowledgeDataMap中
        {
            NSMapTable *queryMap = nil;
            
            // 在map中查找, 若无, 则创建
            id obj = [self.knowledgeDataMap objectForKey:dataId];
            if (obj == nil) {
                // <query_id, {data_file_name, offset, len, last_used_time}>
                queryMap = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
                [queryMap setObject:index forKey:queryId];
                LogInfo(@"[KnowledgeDataLoader-loadKnowledgeIndex:forData:] loaded index to memory, the index is: %@", [queryMap objectForKey:queryId]);
                [self.knowledgeDataMap setObject:queryMap forKey:dataId];
            }
            else {
                queryMap = (NSMapTable *)obj;
                [queryMap setObject:index forKey:queryId];
            }
        }
    }
    
    fclose(fp);
    
    return YES;
}

#pragma mark - test
- (BOOL)test {
    NSString *dataId = @"9999eed5e71a0ff16bafc9f082bc9999";
    NSString *queryId = @"0";
    
    NSString *knowledgeDataRootPathInApp = [[Config instance] knowledgeDataConfig].knowledgeDataRootPathInApp;
    
    NSString *indexFilename = [NSString stringWithFormat:@"%@/%@", knowledgeDataRootPathInApp, @"kaoyan^book_index_data^english#english_realexam_2010/index_8"];
    NSString *data = [self getKnowledgeDataWithDataId:dataId andQueryId:queryId andIndexFilename:indexFilename];
    
    return YES;
}

@end
