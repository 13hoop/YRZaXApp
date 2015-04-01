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

@synthesize bookCategory;
@synthesize bookMeta;
@synthesize coverSrc;
@synthesize completeBookId;
@synthesize bookReadType;

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
    knowledgeMeta.dataStatusDesc = knowledgeMetaEntity.dataStatusDesc;
    
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
    //2.0中新增几个字段

    knowledgeMeta.bookCategory = knowledgeMetaEntity.bookCategory;
    knowledgeMeta.coverSrc = knowledgeMetaEntity.coverSrc;
    knowledgeMeta.bookMeta = knowledgeMetaEntity.bookMeta;
    knowledgeMeta.completeBookId = knowledgeMetaEntity.completeBookId;
    knowledgeMeta.bookReadType = knowledgeMetaEntity.bookReadType;
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
    //2.0中新增的四个字段
    
    //bookMeta
    if (self.bookMeta != nil && self.bookMeta.length > 0) {
        [knowledgeMetaEntity setValue:self.bookMeta forKey:@"bookMeta"];
    }
    else {
        [knowledgeMetaEntity setValue:@"" forKey:@"bookMeta"];
        
    }
    
    //bookCategory
    if (self.bookCategory != nil && self.bookCategory.length > 0) {
        [knowledgeMetaEntity setValue:self.bookCategory forKey:@"bookCategory"];
    }
    else {
        [knowledgeMetaEntity setValue:@"" forKey:@"bookCategory"];
 
    }
    
    //coverSrc
    if (self.coverSrc != nil && self.coverSrc.length > 0) {
        [knowledgeMetaEntity setValue:self.coverSrc forKey:@"coverSrc"];

    }
    else {
        [knowledgeMetaEntity setValue:@"" forKey:@"coverSrc"];

    }
    
    //completeBookId
    if (self.completeBookId != nil && self.completeBookId.length > 0) {
        [knowledgeMetaEntity setValue:self.completeBookId forKey:@"completeBookId"];

    }
    else {
        [knowledgeMetaEntity setValue:@"" forKey:@"completeBookId"];
    }
    
    //bookReadType
    if (self.bookReadType != nil && self.bookReadType.length > 0) {
        [knowledgeMetaEntity setValue:self.bookReadType forKey:@"bookReadType"];
        
    }
    else {
        [knowledgeMetaEntity setValue:@"" forKey:@"bookReadType"];
    }
    
    
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

//将在发现页中点的一本书的信息写到数据库中
//存到数据库之前的将json数据转换成knowledgeMeta的操作，或者不转换也行，没有的就不转换，直接存空字符串进去。
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
#pragma mark for  2.0 parse server response book_meta dic
+ (KnowledgeMeta *)parseBookMetaDic:(NSDictionary *)bookMetaDic {
    
    
    if(bookMetaDic == nil) {
        return nil;
    }
    //1解析服务器响应的data对应的字典
    //data_meta 直接将这个字符串存到数据库中就可以。
    NSString *dataMeta = [bookMetaDic objectForKey:@"data_meta"];
    //data_id 保存到数据库
    NSString *dataId = [bookMetaDic objectForKey:@"data_id"];
    //complete_book_id 主要目的是用来找到存放到数据库中的试读数据的相对路径
    NSString *completeBookId = [bookMetaDic objectForKey:@"complete_book_id"];
    //data_version,存到数据库中的latestVersion中
    NSString *dataVersion = [bookMetaDic objectForKey:@"data_version"];
    //data_category,存到数据库
    NSString *dataCategory = [bookMetaDic objectForKey:@"data_category"];
    //data_type 保存到数据库
    NSString *dataType = [bookMetaDic objectForKey:@"data_type"];
    
    //cover_src 1把封面图片拉倒本地 2将图片在sandBox的相对地址存到数据库中 3返给JS的是图片在app中的地址（file://格式）
    NSString *coverSrc = [bookMetaDic objectForKey:@"cover_src"];
    
    NSURL *coverUrl = [NSURL URLWithString:coverSrc];
    NSString *lastPartMent = [coverUrl lastPathComponent];//图片名
    NSString *extension = [[lastPartMent componentsSeparatedByString:@"."] lastObject];//图片拓展名 png jpg
    NSString *insideSandBoxPath = [NSString stringWithFormat:@"knowledge_data/coverImage/%@/%@",dataId,lastPartMent];
    //将服务器响应的信息，存到knowledgeMeta对象中。
    KnowledgeMeta *knowledgeMeta = [[KnowledgeMeta alloc] init];
    
    knowledgeMeta.dataId = dataId;
    knowledgeMeta.bookCategory = dataCategory;
    knowledgeMeta.bookMeta = dataMeta;
    knowledgeMeta.completeBookId =completeBookId;
    knowledgeMeta.coverSrc = insideSandBoxPath;//在第一次加载的时候就将coverImage的相对路径存到数据库中。
    
    
    knowledgeMeta.dataNameEn = @"";
    knowledgeMeta.dataNameCh = @"";
    knowledgeMeta.desc = @"";
    knowledgeMeta.dataType = DATA_TYPE_DATA_SOURCE;
    if ([dataType isEqualToString:@"complete_book"]) {//整书
    knowledgeMeta.bookReadType = @"全书";
    }
    else  if([dataType isEqualToString:@"partial_book"]){
        //试读数据
        knowledgeMeta.bookReadType = @"试读";
    }
    else {
        knowledgeMeta.bookReadType = @"未知";
    }
    
    knowledgeMeta.dataStorageType = DATA_STORAGE_INTERNAL_STORAGE;
    knowledgeMeta.dataPathType = DATA_PATH_TYPE_FILE;//先置为0,后续有影响再修改
    knowledgeMeta.dataPath = @"";//这时是没有数据的存储路径的，只有下载或者更新后才会有这个字段
    
    knowledgeMeta.dataSearchType = DATA_SEARCH_IGNORE;//搜索类型先置为0
    
    knowledgeMeta.dataStatus = DATA_STATUS_UNKNOWN;//必须是未下载状态，很重要。
    knowledgeMeta.dataStatusDesc = @"";
    
    knowledgeMeta.parentId = @"";
    knowledgeMeta.parentNameEn = @"";
    knowledgeMeta.parentNameCh = @"";
    
    knowledgeMeta.childIds = nil;
    
    // sibling ids
    knowledgeMeta.siblingIds = nil;
            
    knowledgeMeta.nodeContentDir = @"";
    knowledgeMeta.isUpdateSeed = NO;//是否为更新依据，默认置为NO
    
    // update time
    {
        knowledgeMeta.updateTime = nil;
        
        NSDate *curDate = [NSDate date];
        knowledgeMeta.updateTime = curDate;
    }
    
    knowledgeMeta.updateType = DATA_UPDATE_TYPE_NODE;
    knowledgeMeta.updateInfo = @"";
    
    // check time
    {
        knowledgeMeta.checkTime = nil;
        NSDate *curDate = [NSDate date];
        knowledgeMeta.checkTime = curDate;//需要修改
        
    }
    
    knowledgeMeta.curVersion = @"";//当前版本号一定要置为空，很重要
    
    // latest version
    {
        knowledgeMeta.latestVersion = dataVersion;//书籍未下载，将从服务器获取到的版本号存到latestVersion字段。
//        if (knowledgeMeta.latestVersion == nil) {
//            knowledgeMeta.latestVersion = knowledgeMeta.curVersion;
//        }
    }
    
    // release time
    {
        knowledgeMeta.releaseTime = nil;
    }
    
    // search reverse info
    {
        knowledgeMeta.searchReverseInfo = nil;//暂时先置为空
    }
    

    
    return knowledgeMeta;
}

@end
