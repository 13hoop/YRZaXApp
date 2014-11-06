//
//  KnowledgeDataLoader.m
//  ebooksystem
//
//  Created by zhenghao on 10/21/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeDataLoader.h"

#import "KnowledgeMetaManager.h"


#import "Config.h"

#import "LogUtil.h"


#include <stdio.h>



// index文件中, 每行的最大长度, B
#define MAX_LINE_LENGTH 1024



// knowledge data index
@interface KnowledgeDataIndex : NSObject

// 数据文件全路径
@property (nonatomic, copy) NSString *fullDataFilepath;
// 数据在数据文件中的offset
@property (nonatomic, assign) NSInteger offset;
// 数据在数据文件中的len
@property (nonatomic, assign) NSInteger len;

// 此index的上一次使用时间
@property (nonatomic, copy) NSDate *lastUsedTime;

@end



// knowledge data loader
@interface KnowledgeDataLoader()

#pragma mark - properties
// knowledge data map
// <data_id, <query_id, [{data_file_name, offset, len, last_used_time}, ...]>>
@property (nonatomic, retain) NSMutableDictionary *knowledgeDataDict;

#pragma mark - load knowledge data
// 根据knowledgeDataIndex, 加载knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeDataIndex *)dataIndex;

#pragma mark - decide index filename according to query id
// 根据queryId计算index文件名
- (NSString *)decideIndexFilename:(NSString *)queryId;

#pragma mark - load knowledge index file
// 加载index文件
- (BOOL)loadKnowledgeIndex:(NSString *)indexFilename forData:(NSString *)dataId;


@end



@implementation KnowledgeDataIndex

@synthesize fullDataFilepath;
@synthesize offset;
@synthesize len;
@synthesize lastUsedTime;

@end



@implementation KnowledgeDataLoader

@synthesize knowledgeDataDict = _knowledgeDataDict;



#pragma mark - properties
- (NSMutableDictionary *)knowledgeDataDict {
    if (_knowledgeDataDict == nil) {
        _knowledgeDataDict = [[NSMutableDictionary alloc] init];
    }
    
    return _knowledgeDataDict;
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
// 根据queryId计算index文件名
- (NSString *)decideIndexFilename:(NSString *)queryId {
    NSInteger factor = 31;
    NSInteger maxIndexFileCount = 20;
    
    NSInteger val = 0;
    for (int i = 0; i < queryId.length; ++i) {
        NSInteger ascii = [queryId characterAtIndex:i];
        val += ascii;
        
        val *= factor;
        val %= maxIndexFileCount;
    }
    
    val %= maxIndexFileCount;
    
    NSString *indexFilename = [NSString stringWithFormat:@"index_%ld", (long)val];
    return indexFilename;
}

// 根据dataId, queryId, 和indexFilename加载knowledge data
- (NSArray *)getKnowledgeDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId andIndexFilename:(NSString *)indexFilename {
    // 1. 根据需要, 加载index文件
    {
        BOOL shouldLoadIndex = NO;
        
        do {
            id dataObj = [self.knowledgeDataDict objectForKey:dataId];
            if (dataObj == nil) {
                shouldLoadIndex = YES;
                break;
            }
            
            NSMutableDictionary *queryDict = (NSMutableDictionary *)dataObj;
            if (queryDict == nil) {
                shouldLoadIndex = YES;
                break;
            }
            
            id queryObj = [queryDict objectForKey:queryId];
            if (queryObj == nil) {
                shouldLoadIndex = YES;
                break;
            }
            
            NSMutableArray *indexArray = (NSMutableArray *)queryObj;
            if (indexArray == nil || indexArray.count <= 0) {
                shouldLoadIndex = YES;
                break;
            }
        } while (0);
        
        if (shouldLoadIndex) {
            // try load the index file
            if (indexFilename == nil || indexFilename.length <= 0) {
                indexFilename = [self decideIndexFilename:queryId];
            }
            
            BOOL ret = [self loadKnowledgeIndex:indexFilename forData:dataId];
            if (!ret) {
                LogError(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since fail to load index from file: %@", indexFilename);
                return nil;
            }
        }
    }
    
    // 2. 获取knowledge data
    id dataObj = [self.knowledgeDataDict objectForKey:dataId];
    if (dataObj == nil) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since fail to find data for data id: %@", dataId);
        return nil;
    }
    
    // <query_id, [{data_file_name, offset, len, last_used_time}, ...]>
    NSMutableDictionary *queryDict = (NSMutableDictionary *)dataObj;
    if (queryDict == nil) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since no query dict for query id: %@", queryId);
        return nil;
    }
    
    id queryObj = [queryDict objectForKey:queryId];
    if (queryObj == nil) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since query obj is nil for query id: %@", queryId);
        return nil;
    }
    
    NSMutableArray *indexArray = (NSMutableArray *)queryObj;
    if (indexArray == nil || indexArray.count <= 0) {
        LogWarn(@"[KnowledgeLoader-getKnowledgeDataWithDataId:andQueryId:andIndexFilename:] failed since there is no index data for query id: %@", queryId);
        return nil;
    }
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (id indexObj in indexArray) {
        KnowledgeDataIndex *dataIndex = (KnowledgeDataIndex *)indexObj;
        if (dataIndex == nil) {
            continue;
        }
        
        dataIndex.lastUsedTime = [NSDate date];
        
        NSString *data = [self loadKnowledgeData:dataIndex];
        if (data != nil && data.length > 0) {
            [resultArray addObject:data];
        }
    }
    
    return resultArray;
}

// 根据knowledgeDataIndex, 加载knowledge data
- (NSString *)loadKnowledgeData:(KnowledgeDataIndex *)dataIndex {
    if (dataIndex == nil || dataIndex.fullDataFilepath == nil || dataIndex.fullDataFilepath.length <= 0) {
        return nil;
    }
    
    NSString *data = nil;
    do {
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:dataIndex.fullDataFilepath];
        if (fileHandler == nil) {
            LogError(@"[KnowledgeDataLoader-loadKnowledgeData:] failed to open file: %@", dataIndex.fullDataFilepath);
            break;
        }
        
        [fileHandler seekToFileOffset:dataIndex.offset];
        
        NSData *buffer = [fileHandler readDataOfLength:dataIndex.len];
        if (buffer == nil) {
            break;
        }
        
        data = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
        
        [fileHandler closeFile];
    } while (0);
    
    return data;
}

#pragma mark - load knowledge index file
// 加载index文件
- (BOOL)loadKnowledgeIndex:(NSString *)indexFilename forData:(NSString *)dataId {
    NSArray *knowledgeMetaEntities = [[KnowledgeMetaManager instance] getKnowledgeMetaWithDataId:dataId];
    
    // add
    if (knowledgeMetaEntities == nil || knowledgeMetaEntities.count <= 0) {
        return NO;
    }
    
    KnowledgeMeta *targetKnowledgeMeta = nil;
    for (id obj in knowledgeMetaEntities) {
        KnowledgeMetaEntity *knowledgeMetaEntity = (KnowledgeMetaEntity *)obj;
        if (knowledgeMetaEntity == nil) {
            continue;
        }
        
        KnowledgeMeta *knowledgeMeta = [KnowledgeMeta fromKnowledgeMetaEntity:knowledgeMetaEntity];
        if (knowledgeMeta) {
            targetKnowledgeMeta = knowledgeMeta;
            break;
        }
    }
    
    if (targetKnowledgeMeta == nil || targetKnowledgeMeta.dataPath == nil || targetKnowledgeMeta.dataPath.length <= 0) {
        return NO;
    }

    // 逐行读取文件
    NSString *fullIndexFilepath = [NSString stringWithFormat:@"%@/%@/%@", [Config instance].knowledgeDataConfig.knowledgeDataRootPathInApp, targetKnowledgeMeta.dataPath, indexFilename];
    
    FILE *fp = fopen([fullIndexFilepath UTF8String], "r");
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
        index.fullDataFilepath = [NSString stringWithFormat:@"%@/%@/%@", [Config instance].knowledgeDataConfig.knowledgeDataRootPathInApp, targetKnowledgeMeta.dataPath, dataFilename];
        index.offset = offset;
        index.len = len;
        
        // 添加到knowledgeDataMap中
        {
            NSMutableDictionary *queryDict = nil;
            
            // 在dict中查找, 若无, 则创建
            id obj = [self.knowledgeDataDict objectForKey:dataId];
            if (obj == nil) {
                // <query_id, [{data_file_name, offset, len, last_used_time}, ...]>
                NSMutableArray *indexArray = [[NSMutableArray alloc] init];
                [indexArray addObject:index];
                
                queryDict = [[NSMutableDictionary alloc] init];
                [queryDict setObject:indexArray forKey:queryId];
                
//                queryDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:index, nil] forKeys:[NSArray arrayWithObjects:queryId, nil]];
                [self.knowledgeDataDict setObject:queryDict forKey:dataId];
            }
            else {
                queryDict = (NSMutableDictionary *)obj;
                if (queryDict == nil) {
                    queryDict = [[NSMutableDictionary alloc] init];
                }
                
                if (queryDict) {
                    NSMutableArray *indexArray = [queryDict objectForKey:queryId];
                    if (indexArray == nil) {
                        indexArray = [[NSMutableArray alloc] init];
                    }
                    
                    [indexArray addObject:index];
                    
                    [queryDict setObject:indexArray forKey:queryId];
//                    [queryDict setObject:index forKey:queryId];
                }
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
