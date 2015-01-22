//
//  KnowledgeMeta.m
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "KnowledgeMeta.h"

#import "KnowledgeSearchReverseInfo.h"
#import "KnowledgeMetaEntity.h"
#import "KnowledgeSearchEntity.h"

#import "LogUtil.h"



@interface KnowledgeMeta()

// 解析meta.json中的search_reverse_info
+ (NSArray *)parseSearchReverseInfo:(NSArray *)jsonArray;


@end



@implementation KnowledgeMeta

@synthesize dataId;
@synthesize dataNameEn;
@synthesize dataNameCh;
@synthesize desc;

@synthesize dataType;
@synthesize dataStorageType;
@synthesize dataPathType;
@synthesize dataPath;

@synthesize dataSearchType;

@synthesize dataStatus;
@synthesize dataStatusDesc;

@synthesize parentId;
@synthesize parentNameEn;
@synthesize parentNameCh;

@synthesize childIds;
@synthesize siblingIds;

@synthesize nodeContentDir;

@synthesize isUpdateSeed;

@synthesize updateTime;
@synthesize updateType;
@synthesize updateInfo;

@synthesize checkTime;
@synthesize curVersion;
@synthesize latestVersion;
@synthesize releaseTime;

@synthesize searchReverseInfo;


#pragma mark - 与KnowledgeMetaEntity转换
// 由KnowledgeMetaEntity转为KnowledgeMeta
+ (KnowledgeMeta *)fromKnowledgeMetaEntity:(KnowledgeMetaEntity *)knowledgeMetaEntity {
    if (knowledgeMetaEntity == nil) {
        return nil;
    }
    
    KnowledgeMeta *knowledgeMeta = [[KnowledgeMeta alloc] init];
    
    knowledgeMeta.dataId = knowledgeMetaEntity.dataId;
    knowledgeMeta.dataNameEn = knowledgeMetaEntity.dataNameEn;
    knowledgeMeta.dataNameCh = knowledgeMetaEntity.dataNameCh;
    knowledgeMeta.desc = knowledgeMetaEntity.desc;
    
    knowledgeMeta.dataType = (DataType)[knowledgeMetaEntity.dataType integerValue];
    knowledgeMeta.dataStorageType = (DataStorageType)[knowledgeMetaEntity.dataStorageType integerValue];
    knowledgeMeta.dataPathType = (DataPathType)[knowledgeMetaEntity.dataPathType integerValue];
    knowledgeMeta.dataPath = knowledgeMetaEntity.dataPath;
    
    knowledgeMeta.dataSearchType = (DataSearchType)[knowledgeMetaEntity.dataSearchType integerValue];
    
    knowledgeMeta.dataStatus = (DataStatus)[knowledgeMetaEntity.dataStatus integerValue];
    knowledgeMeta.dataStatusDesc = knowledgeMeta.dataStatusDesc;
    
    knowledgeMeta.parentId = knowledgeMetaEntity.parentId;
    knowledgeMeta.parentNameEn = knowledgeMetaEntity.parentNameEn;
    knowledgeMeta.parentNameCh = knowledgeMetaEntity.parentNameCh;
    
    // child ids
    {
        if (knowledgeMetaEntity.childIds != nil && knowledgeMetaEntity.childIds.length > 0) {
            knowledgeMeta.childIds = [knowledgeMetaEntity.childIds componentsSeparatedByString:@","];
        }
    }
    
    // sibling ids
    {
        if (knowledgeMetaEntity.siblingIds != nil && knowledgeMetaEntity.siblingIds.length > 0) {
            knowledgeMeta.siblingIds = [knowledgeMetaEntity.siblingIds componentsSeparatedByString:@","];
        }
    }
    
    knowledgeMeta.nodeContentDir = knowledgeMetaEntity.nodeContentDir;
    
    knowledgeMeta.isUpdateSeed = [knowledgeMetaEntity.isUpdateSeed boolValue];
    
    knowledgeMeta.updateTime = knowledgeMetaEntity.updateTime;
    knowledgeMeta.updateType = (DataUpdateType)[knowledgeMetaEntity.updateType integerValue];
    knowledgeMeta.updateInfo = knowledgeMetaEntity.updateInfo;
    
    knowledgeMeta.checkTime = knowledgeMetaEntity.checkTime;
    knowledgeMeta.curVersion = knowledgeMetaEntity.curVersion;
    knowledgeMeta.latestVersion = knowledgeMetaEntity.latestVersion;
    knowledgeMeta.releaseTime = knowledgeMetaEntity.releaseTime;
    
    return knowledgeMeta;
}

// 将KnowledgeMeta各属性赋予KnowledgeMetaEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)knowledgeMetaEntity {
    if (knowledgeMetaEntity == nil) {
        return NO;
    }
    
    [knowledgeMetaEntity setValue:self.dataId forKey:@"dataId"];
    [knowledgeMetaEntity setValue:self.dataNameEn forKey:@"dataNameEn"];
    [knowledgeMetaEntity setValue:self.dataNameCh forKey:@"dataNameCh"];
    [knowledgeMetaEntity setValue:self.desc forKey:@"desc"];
    
    [knowledgeMetaEntity setValue:[NSNumber numberWithInteger:self.dataType] forKey:@"dataType"];
    [knowledgeMetaEntity setValue:[NSNumber numberWithInteger:self.dataStorageType] forKey:@"dataStorageType"];
    [knowledgeMetaEntity setValue:[NSNumber numberWithInteger:self.dataPathType] forKey:@"dataPathType"];
    [knowledgeMetaEntity setValue:self.dataPath forKey:@"dataPath"];
    
    [knowledgeMetaEntity setValue:[NSNumber numberWithInteger:self.dataSearchType] forKey:@"dataSearchType"];
    
    [knowledgeMetaEntity setValue:[NSNumber numberWithInteger:self.dataStatus] forKey:@"dataStatus"];
    [knowledgeMetaEntity setValue:self.dataStatusDesc forKey:@"dataStatusDesc"];
    
    [knowledgeMetaEntity setValue:self.parentId forKey:@"parentId"];
    [knowledgeMetaEntity setValue:self.parentNameEn forKey:@"parentNameEn"];
    [knowledgeMetaEntity setValue:self.parentNameCh forKey:@"parentNameCh"];
    
    // child ids
    {
        if (self.childIds != nil && self.childIds.count > 0) {
            [knowledgeMetaEntity setValue:[self.childIds componentsJoinedByString:@","] forKey:@"childIds"];
        }
    }
    
    // sibling ids
    {
        if (self.siblingIds != nil && self.siblingIds.count > 0) {
            [knowledgeMetaEntity setValue:[self.siblingIds componentsJoinedByString:@","] forKey:@"siblingIds"];
        }
    }
    
    [knowledgeMetaEntity setValue:self.nodeContentDir forKey:@"nodeContentDir"];
    
    [knowledgeMetaEntity setValue:[NSNumber numberWithBool:self.isUpdateSeed] forKey:@"isUpdateSeed"];
    [knowledgeMetaEntity setValue:self.parentNameCh forKey:@"parentNameCh"];

    [knowledgeMetaEntity setValue:self.updateTime forKey:@"updateTime"];
    [knowledgeMetaEntity setValue:[NSNumber numberWithInteger:self.updateType] forKey:@"updateType"];
    [knowledgeMetaEntity setValue:self.updateInfo forKey:@"updateInfo"];
    
    [knowledgeMetaEntity setValue:self.checkTime forKey:@"checkTime"];
    [knowledgeMetaEntity setValue:self.curVersion forKey:@"curVersion"];
    [knowledgeMetaEntity setValue:self.latestVersion forKey:@"latestVersion"];
    [knowledgeMetaEntity setValue:self.releaseTime forKey:@"releaseTime"];

    return YES;
}

//// 由KnowledgeMeta转为KnowledgeSearchEntity
//- (NSArray *)toKnowledgeSearchEntity {
//    if (self.searchReverseInfo == nil || self.searchReverseInfo.count <= 0) {
//        return nil;
//    }
//    
//    NSMutableArray *searchEnties = [[NSMutableArray alloc] init];
//    
//    for (id obj in self.searchReverseInfo) {
//        KnowledgeSearchReverseInfo *knowledgeSearchReverseInfo = (KnowledgeSearchReverseInfo *)obj;
//        if (knowledgeSearchReverseInfo == nil || knowledgeSearchReverseInfo.searchResults == nil || knowledgeSearchReverseInfo.searchResults.count <= 0) {
//            continue;
//        }
//        
//        for (id result in knowledgeSearchReverseInfo.searchResults) {
//            KnowledgeSearchResultItem *knowledgeSearchResultItem = (KnowledgeSearchResultItem *)result;
//            if (knowledgeSearchResultItem == nil) {
//                continue;
//            }
//            
//            KnowledgeSearchEntity *knowledgeSearchEntity = [[KnowledgeSearchEntity alloc] init];
//            
//            knowledgeSearchEntity.searchId = knowledgeSearchReverseInfo.searchId;
//            knowledgeSearchEntity.dataId = knowledgeSearchResultItem.dataId;
//            knowledgeSearchEntity.dataNameEn = knowledgeSearchResultItem.dataNameEn;
//            knowledgeSearchEntity.dataNameCh = knowledgeSearchResultItem.dataNameCh;
//            
//            [searchEnties addObject:knowledgeSearchEntity];
//        }
//    }
//    
//    return searchEnties;
//}

// parse knowledge meta from json string
+ (KnowledgeMeta *)parseJsonString:(NSString *)json {
    if (json == nil || json.length <= 0) {
        return nil;
    }
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil || data.length <= 0) {
        return nil;
    }

    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (dict == nil || dict.count <= 0) {
        LogError(@"[KnowledgeMeta-parseJsonString()]failed to parse json, json str: %@, error: %@", json, [error localizedDescription]);
        return nil;
    }
    
    KnowledgeMeta *knowledgeMeta = [[KnowledgeMeta alloc] init];
    
    knowledgeMeta.dataId = [dict objectForKey:@"id"];
    knowledgeMeta.dataNameEn = [dict objectForKey:@"data_name_en"];
    knowledgeMeta.dataNameCh = [dict objectForKey:@"data_name_ch"];
    knowledgeMeta.desc = [dict objectForKey:@"desc"];
    
    knowledgeMeta.dataType = DATA_TYPE_DATA_SOURCE;
    knowledgeMeta.dataStorageType = DATA_STORAGE_APP_ASSETS;
    knowledgeMeta.dataPathType = (DataPathType)[[dict objectForKey:@"path_type"] integerValue];
    knowledgeMeta.dataPath = [dict objectForKey:@"path"];
    
    knowledgeMeta.dataSearchType = (DataSearchType)[[dict objectForKey:@"data_store_type"] integerValue];

    knowledgeMeta.dataStatus = DATA_STATUS_AVAIL;
    knowledgeMeta.dataStatusDesc = [dict objectForKey:@"update_info"];
    
    knowledgeMeta.parentId = [dict objectForKey:@"parent_id"];
    knowledgeMeta.parentNameEn = [dict objectForKey:@"parent_name_en"];
    knowledgeMeta.parentNameCh = [dict objectForKey:@"parent_name_ch"];

    // child ids
    {
        knowledgeMeta.childIds = nil;
        NSString *childIds = [dict objectForKey:@"child_id_arr"];
        if (childIds != nil && childIds.length > 0) {
            NSArray *childIdsArray = [childIds componentsSeparatedByString:@","];
            if (childIdsArray != nil && childIdsArray.count > 0) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                
                for (NSString *childId in childIdsArray) {
                    if (childId == nil || childId.length <= 0) {
                        continue;
                    }
                    
                    [array addObject:childId];
                }
                
                if (array != nil && array.count > 0) {
                    knowledgeMeta.childIds = array;
                }
            }
        }
    }
    
    // sibling ids
    {
        knowledgeMeta.siblingIds = nil;
        NSString *siblingIds = [dict objectForKey:@"sibling_id_arr"];
        if (siblingIds != nil && siblingIds.length > 0) {
            NSArray *siblingIdsArray = [siblingIds componentsSeparatedByString:@","];
            if (siblingIdsArray != nil && siblingIdsArray.count > 0) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                
                for (NSString *siblingId in siblingIdsArray) {
                    if (siblingId == nil || siblingId.length <= 0) {
                        continue;
                    }
                    
                    [array addObject:siblingId];
                }
                
                if (array != nil && array.count > 0) {
                    knowledgeMeta.siblingIds = array;
                }
            }
        }
    }
    
    knowledgeMeta.nodeContentDir = [dict objectForKey:@"child_dir"];
    knowledgeMeta.isUpdateSeed = [[dict objectForKey:@"is_update_seed"] boolValue];

    // update time
    {
        knowledgeMeta.updateTime = nil;
        
        NSString *timeStr = [dict objectForKey:@"update_time"];
        if (timeStr != nil && timeStr.length > 0) {
            long long timeVal = [timeStr longLongValue];
            knowledgeMeta.updateTime = [NSDate dateWithTimeIntervalSince1970:timeVal];
        }
    }
    
    knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
    knowledgeMeta.updateInfo = [dict objectForKey:@"update_info"];

    // check time
    {
        knowledgeMeta.checkTime = nil;
        
        NSString *timeStr = [dict objectForKey:@"check_time"];
        if (timeStr != nil && timeStr.length > 0) {
            long long timeVal = [timeStr longLongValue];
            knowledgeMeta.checkTime = [NSDate dateWithTimeIntervalSince1970:timeVal];
        }
    }
    
    knowledgeMeta.curVersion = [dict objectForKey:@"version"];
    
    // latest version
    {
        knowledgeMeta.latestVersion = [dict objectForKey:@"latest_version"];
        if (knowledgeMeta.latestVersion == nil) {
            knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
        }
    }
    
    // release time
    {
        knowledgeMeta.releaseTime = nil;
        
        NSString *timeStr = [dict objectForKey:@"release_time"];
        if (timeStr != nil && timeStr.length > 0) {
            long long timeVal = [timeStr longLongValue];
            knowledgeMeta.releaseTime = [NSDate dateWithTimeIntervalSince1970:timeVal];
        }
    }

    // search reverse info
    {
        NSArray *searchReverseInfoArr = [dict objectForKey:@"search_reverse_info"];
        knowledgeMeta.searchReverseInfo = [KnowledgeMeta parseSearchReverseInfo:searchReverseInfoArr];
    }
    
    return knowledgeMeta;
}

// 解析meta.json中的search_reverse_info
+ (NSArray *)parseSearchReverseInfo:(NSArray *)jsonArray {
//    LogDebug(@"%@", jsonArray);
    
    // search reverse info array
    NSMutableArray *searchReverseInfoArray = [[NSMutableArray alloc] init];
    
    for (id obj in jsonArray) {
        NSDictionary *dict = (NSDictionary *)obj;
        if (dict == nil || dict.count <= 0) {
            continue;
        }
        
        // search id
        // 注: 此处的query可能为long, 故需将其转为string
        // e.g, {
//        query = 230103;
//        "search_result" =         (
//                                   {
//                                       "data_name_en" = "kaoyan^book_detail_page^politics#politics_xuanzetinandian#shigang#kaodian3";
//                                       id = ff908ff28cbb090d9d91d121cafecd99;
//                                   }
//                                   )
        id searchIdObj = [dict objectForKey:@"query"];
        if (searchIdObj == nil) {
            continue;
        }
        
        NSString *searchId = [NSString stringWithFormat:@"%@", searchIdObj];
        if (searchId == nil || searchId.length <= 0) {
            continue;
        }
        
        // search results
        NSArray *searchResultsArray = [dict objectForKey:@"search_result"];
        if (searchResultsArray == nil || searchResultsArray.count <= 0) {
            continue;
        }
        
        // 遍历search_item
        NSMutableArray *searchResultItems = [[NSMutableArray alloc] init];
        for (id objSearchResult in searchResultsArray) {
            NSDictionary *dictSearchResult = (NSDictionary *)objSearchResult;
            if (dictSearchResult == nil || dictSearchResult.count <= 0) {
                continue;
            }
            
            KnowledgeSearchResultItem *item = [[KnowledgeSearchResultItem alloc] init];
            item.dataId = [dictSearchResult objectForKey:@"id"];
            item.dataNameEn = [dictSearchResult objectForKey:@"data_name_en"];
            item.dataNameCh = [dictSearchResult objectForKey:@"data_name_ch"];
            
            if (item.dataId != nil && item.dataId.length > 0) {
                [searchResultItems addObject:item];
            }
        }
        
        if (searchResultItems != nil && searchResultItems.count > 0) {
            KnowledgeSearchReverseInfo *knowledgeSearchReverseInfo = [[KnowledgeSearchReverseInfo alloc] init];
            knowledgeSearchReverseInfo.searchId = searchId;
            knowledgeSearchReverseInfo.searchResults = searchResultItems;
            
            [searchReverseInfoArray addObject:knowledgeSearchReverseInfo];
        }
    }

    // 返回
    if (searchReverseInfoArray == nil || searchReverseInfoArray.count <= 0) {
        return nil;
    }
    
    return searchReverseInfoArray;
}

@end
