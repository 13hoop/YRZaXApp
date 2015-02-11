//
//  scanQRcodeDataManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/5.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "scanQRcodeDataManager.h"
#import "LogUtil.h"
#import "Config.h"

#include <stdio.h>

// index文件中, 每行的最大长度, B
#define MAX_LINE_LENGTH 1024


// map data index
@interface mapDataIndex : NSObject

// 数据文件全路径
@property (nonatomic, copy) NSString *fullDataFilepath;
// 数据在数据文件中的offset
@property (nonatomic, assign) NSInteger offset;
// 数据在数据文件中的len
@property (nonatomic, assign) NSInteger len;

// 此index的上一次使用时间
@property (nonatomic, copy) NSDate *lastUsedTime;

@end









//
@interface scanQRcodeDataManager ()

//同样构造dic，同index加载shit中数据的方式
@property (nonatomic, retain) NSMutableDictionary *knowledgeDataDict;

//根据dataId和queryId来获取scanInfoItem
- (NSArray *)getBookInfoDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId;
//计算index文件名
- (NSString *)decideMapFilename:(NSString *)queryId;
//加载map文件
- (BOOL)loadKnowledgeIndexWithBookNumber:(NSString *)bookNumber;


#pragma mark - load knowledge data

@end


//implementation的声明实现必须有，否则会导致报错
@implementation mapDataIndex

@synthesize fullDataFilepath;
@synthesize offset;
@synthesize len;
@synthesize lastUsedTime;

@end

@implementation scanResultItem

@synthesize bookIdInMap;
@synthesize queryIdInMap;
@synthesize pageTypeInMap;
@synthesize descInMap;
@synthesize pageArgsInMap;

@end



@implementation scanQRcodeDataManager




@synthesize knowledgeDataDict = _knowledgeDataDict;



#pragma mark - properties
- (NSMutableDictionary *)knowledgeDataDict {
    if (_knowledgeDataDict == nil) {
        _knowledgeDataDict = [[NSMutableDictionary alloc] init];
    }
    
    return _knowledgeDataDict;
}

#pragma mark 单例
+ (scanQRcodeDataManager *)instance {
    static scanQRcodeDataManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[scanQRcodeDataManager alloc] init];
    });
    
    return sharedInstance;
}





#pragma mark - decide index filename according to pageNumber
//根据页码来得到map文件名称
- (NSString *)decideMapFilename:(NSString *)queryId {
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
    
    NSString *mapFilename = [NSString stringWithFormat:@"index_%ld", (long)val];
    return mapFilename;
}







#pragma mark - load map file

//加载map文件中的内容（读取文件中的所有记录，构造一个大的dic）
- (BOOL)loadKnowledgeIndexWithBookNumber:(NSString *)bookNumber {

    NSString *fullMapFilepath = [NSString stringWithFormat:@"%@/%@/%@/%@",[[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments,bookNumber,@"data",@"QR_map"];

    //开始读取QR_map文件
    FILE *fp = fopen([fullMapFilepath UTF8String], "r");
    if (fp == NULL) {
        return NO;
    }
    
    char buffer[MAX_LINE_LENGTH];
    while (fgets(buffer, MAX_LINE_LENGTH, fp) != NULL) {
        NSString *line = [NSString stringWithUTF8String:buffer];
        NSArray *fields = [line componentsSeparatedByString:@"\t"];
        if (fields == nil || fields.count < 5) {
            continue;
        }
        
        NSString *bookId = [fields objectAtIndex:0];
        NSString *queryId = [fields objectAtIndex:1];
        NSString *pageType = [fields objectAtIndex:2];
        NSString *desc = [fields objectAtIndex:3];
        NSString *pageArgs = [fields objectAtIndex:4];
        
        scanResultItem *item = [[scanResultItem alloc] init];
        
        item.bookIdInMap = bookId;
        item.queryIdInMap = queryId;
        item.pageTypeInMap = pageType;
        item.pageArgsInMap = pageArgs;
        item.descInMap = desc;
        
        // 添加到map中
        {
            NSMutableDictionary *queryDict = nil;
            
            // 在dict中查找, 若无, 则创建
            id obj = [self.knowledgeDataDict objectForKey:bookNumber];
            if (obj == nil) {//若无，则创建
                // <query_id, [{book_id, query_id, pageType, pageArgs ,desc}, ...]>
                NSMutableArray *indexArray = [[NSMutableArray alloc] init];
                [indexArray addObject:item];
                
                queryDict = [[NSMutableDictionary alloc] init];
                [queryDict setObject:indexArray forKey:queryId];//将文件中的queryId作为key
                
                [self.knowledgeDataDict setObject:queryDict forKey:bookId];//将文件中的bookId作为key
            }
            else {//若是已有，则进行下一步操作
                queryDict = (NSMutableDictionary *)obj;
                if (queryDict == nil) {
                    queryDict = [[NSMutableDictionary alloc] init];
                }
                
                if (queryDict) {//构造一个字典key:value == queryId:indexArray
                    NSMutableArray *indexArray = [queryDict objectForKey:queryId];
                    if (indexArray == nil) {
                        indexArray = [[NSMutableArray alloc] init];
                    }
                    //把item加到indexArray数组中
                    [indexArray addObject:item];
                    //组成dic
                    [queryDict setObject:indexArray forKey:queryId];
                
                }
            }
        }
    }
    
    fclose(fp);
    
    return YES;
}

/*
//这个可能会用不到
#pragma mark - load knowledge data
- (NSString *)loadKnowledgeData:(mapDataIndex *)dataIndex {
    if (dataIndex == nil || dataIndex.fullDataFilepath == nil || dataIndex.fullDataFilepath.length <= 0) {
        return nil;
    }
    
    NSString *data = nil;
    do {
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:dataIndex.fullDataFilepath];
        if (fileHandler == nil) {
            LogError(@"[scanQRcodeDataMaanager-loadKnowledgeData:] failed to open file: %@", dataIndex.fullDataFilepath);
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
*/

#pragma mark load map data from QR_map
/**
 *dataId 是扫描得到的书号
 *queryId 是扫描得到的页号
 *indexfileName 是map文件的名字需要根据页码来计算
 //获取的是scanResultItem数组
 */
//这里的两个参数是由外界传过来的。
- (NSArray *)getBookInfoDataWithDataId:(NSString *)dataId andQueryId:(NSString *)queryId {
    // 1. 根据需要, 加载map文件
    {
        BOOL shouldLoadMapfile = NO;
        
        do {
            id dataObj = [self.knowledgeDataDict objectForKey:dataId];
            if (dataObj == nil) {
                shouldLoadMapfile = YES;
                break;
            }
            
            NSMutableDictionary *queryDict = (NSMutableDictionary *)dataObj;
            if (queryDict == nil) {
                shouldLoadMapfile = YES;
                break;
            }
            
            id queryObj = [queryDict objectForKey:queryId];
            if (queryObj == nil) {
                shouldLoadMapfile = YES;
                break;
            }
            
            NSMutableArray *itemArray = (NSMutableArray *)queryObj;
            if (itemArray == nil || itemArray.count <= 0) {
                shouldLoadMapfile = YES;
                break;
            }
        } while (0);
        
        if (shouldLoadMapfile) {
            
            //结合
            BOOL ret = [self loadKnowledgeIndexWithBookNumber:dataId];
            
            if (!ret) {
                LogError(@"[scanQRcodeDataManager-getBookInfoDataWithDataId:andQueryId:andIndexFilename:] failed since fail to load index from QR_map file");
                return nil;
            }
        }
    }
    
    // 2. 获取scanResultItem
    id dataObj = [self.knowledgeDataDict objectForKey:dataId];
    if (dataObj == nil) {
        LogWarn(@"[scanQRcodeDataManager-getBookInfoDataWithDataId:andQueryId] get map file content failed to find data for data id: %@", dataId);
        return nil;
    }
    
    // <query_id, [{book_id, query_id, pageType, pageArgs , desc }, ...]>
    NSMutableDictionary *queryDict = (NSMutableDictionary *)dataObj;
    if (queryDict == nil) {
        LogWarn(@"[scanQRcodeDataManager-getBookInfoDataWithDataId:andQueryId] fialed to get queryDict for query id: %@", queryId);
        return nil;
    }
    
    id queryObj = [queryDict objectForKey:queryId];
    if (queryObj == nil) {
        LogWarn(@"[scanQRcodeDataManager-getBookInfoDataWithDataId:andQueryId] failed since query obj is nil for query id: %@", queryId);
        return nil;
    }
    
    NSMutableArray *indexArray = (NSMutableArray *)queryObj;//mapIndex文件中可以能有许多的记录，所以是一个数组来存这些书数据。
    if (indexArray == nil || indexArray.count <= 0) {
        LogWarn(@"[scanQRcodeDataManager-getBookInfoDataWithDataId:andQueryId] failed since there is no index data for query id: %@ ,in queryDic", queryId);
        return nil;
    }
    //只需要获取到bookId,queryId对应item数组就行
    
    return indexArray;
    
    
}

//扫描到数据之后应该去先切割字符串，再将各部分的值传给getbookInfowithDataId:queryId:indexfileName:

- (NSArray *)getMapDataByScanInfo:(NSString *)scanInfo {
    //1 、截取bookId和pageNumber
    //    http://zaxue100.com/sao/00101015/4
    NSArray *metaInfoArray = [scanInfo componentsSeparatedByString:@"/"];
    if (metaInfoArray == nil || metaInfoArray.count <= 0) {
        LogError(@"[ scanQRcodeManager - getResultWithScanInfo ]: separate string failed ,the metaInfoArray is nil");
        return nil;
    }
    NSString *pageNumber = [metaInfoArray lastObject];
    NSString *bookNumber = [metaInfoArray objectAtIndex:(metaInfoArray.count - 2)];
    
     NSArray *mapDataArray = [self getBookInfoDataWithDataId:bookNumber andQueryId:pageNumber];
    
    if (mapDataArray == nil || mapDataArray.count <= 0) {
        LogError(@"[scanQRcodeManager - getMapDataByScanInfo]:get map data failed ,no data return from shit");
        return nil;
    }
    
    NSLog(@"从map文件中获取到的数组的值：%@",mapDataArray);
    return mapDataArray;
}

#pragma mark 读map文件中的内容

- (NSArray *)loadMapFileContentWithBookNumber:(NSString *)bookNum andPageNumber:(NSString *)pageNum {
    
    NSMutableArray *mapArray = [[NSMutableArray alloc] init];
    //bookId在这里的作用就是拼接路径用的  --
    //bookId  == ios_bookNumber
    NSString *bookId = [NSString stringWithFormat:@"%@_%@",@"ios",bookNum];
    NSString *queryIdStr = [self decideMapFilename:pageNum];
    //拼接QR_code文件的路径
    NSString *fullMapFilepath = [NSString stringWithFormat:@"%@/%@/%@/%@",[[Config instance] knowledgeDataConfig].knowledgeDataRootPathInDocuments,bookId,@"data",@"QR_code"];
    //读QR_code文件中的内容
    FILE *fp = fopen([fullMapFilepath UTF8String], "r");
    if (fp == NULL) {
        return nil;
    }
    
    char buffer[MAX_LINE_LENGTH];
    while (fgets(buffer, MAX_LINE_LENGTH, fp) != NULL) {
        NSString *line = [NSString stringWithUTF8String:buffer];
        NSArray *fields = [line componentsSeparatedByString:@"\t"];
        if (fields == nil || fields.count < 5) {
            continue;
        }
        
        //若是QR_map文件中的字段发生变化，需要在这里修改。
        NSString *bookId = [fields objectAtIndex:0];
        NSString *queryId = [fields objectAtIndex:1];
        NSString *pageType = [fields objectAtIndex:2];
        NSString *desc = [fields objectAtIndex:3];
        NSString *pageArgs = [fields objectAtIndex:4];
        //去掉pageArgs的前后空格，update时加上bookMarkId，个人中心
        //去掉\n
        NSString *pageArgStr = [pageArgs stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        //去掉字符串左右两边的空格
        pageArgStr = [pageArgStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        scanResultItem *contentIndex = [[scanResultItem alloc] init];
        if ([queryId isEqualToString:queryIdStr]) {
            contentIndex.bookIdInMap = bookId;
            contentIndex.queryIdInMap = queryId;
            contentIndex.pageTypeInMap = pageType;
            contentIndex.pageArgsInMap = pageArgStr;
            contentIndex.descInMap = desc;
            [mapArray addObject:contentIndex];
        }
    }
    fclose(fp);
    return mapArray;
}





@end
