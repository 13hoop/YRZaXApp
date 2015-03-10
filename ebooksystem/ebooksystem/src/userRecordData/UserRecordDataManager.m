//
//  UserRecordDataManager.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/4.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "UserRecordDataManager.h"
#import "BookMarkMeta.h"
#import "UUIDUtil.h"
#import "LogUtil.h"
#import "SBJson.h"



@implementation UserRecordDataManager

#pragma mark -- singleton单例
+ (UserRecordDataManager *)instance {
    static UserRecordDataManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[UserRecordDataManager alloc] init];
    });
    
    return sharedInstance;
}




#pragma mark -- bookMark 
//保存书签
- (BOOL)saveBookMarkMeta:(BookMarkMeta *)bookMarkMeta {
    

    BookMarkMetaManager *manager = [BookMarkMetaManager instance];
     BOOL ret = [manager saveBookMarkMeta:bookMarkMeta];
    return ret;

}

//删除书签
- (BOOL)deleteBookMarkMetaWithUpdateInfoDic:(NSDictionary *)updateDic {

    NSString *bookId = [updateDic objectForKey:@"book_id"];
    NSArray *bookMarkIds = [updateDic objectForKey:@"bookmark_ids"];

    if (bookMarkIds == nil || bookMarkIds.count <= 0) {
        LogError(@"UserRecordDataManager - deleteBookMarkMetaByBookId: andBookMarkId remove booKMark failed because of bookMarkIds nil");
        return NO;
    }
    
    BOOL isDeleted = NO;
    BookMarkMetaManager *manager = [BookMarkMetaManager instance];
    for (NSString *tempBookMarkId in bookMarkIds) {
        
       BOOL ret = [manager deleteBookMarkMetaWithBookId:bookId andBookMarkId:tempBookMarkId];
        isDeleted = ret;
        if (ret == NO) {
            return ret;//删除书签的过程中只要有一个书签没有删除成功，就返回NO
        }
        
    }
    
    return isDeleted;
}
//更新书签
- (BOOL)updateBookMarkMeta:(NSDictionary *)updateDic {
     BookMarkMetaManager *manager = [BookMarkMetaManager instance];
    BOOL ret = [manager updateBookMarkMetaWithLatestBookMarkUpdateInfo:updateDic];
    return ret;
}
//获取书签
- (NSArray *)getBookMarkListWithBookId:(NSString *)bookId andBookType:(NSString *)bookType andQueryId:(NSString *)queryId {
    BookMarkMetaManager *manager = [BookMarkMetaManager instance];
    NSArray *bookMarkListArr = [manager getBookMarkMetaWithBookId:bookId andBookMarkType:bookType andQueryId:queryId];
    
    if (bookMarkListArr.count <= 0 || bookMarkListArr == nil) {
        return nil;
    }
    else {
        //将entity转换成dic
        NSArray *dicArr = [self getBookMarkMetaDicFromBookMarkMetaEntitys:bookMarkListArr];
        return dicArr;
    }

}

//获取所有书签-- bookId为空时调用
- (NSArray *)getAllBookMark {
    BookMarkMetaManager *manager = [BookMarkMetaManager instance];
    NSArray *entityArr = [manager getAllBookMark];
    //将entity转换成dic
    NSArray *dicArray = [self getBookMarkMetaDicFromBookMarkMetaEntitys:entityArr];
    return dicArray;
}

//将获取到的书签数组中的NSManagedObject转成dic
- (NSArray *)getBookMarkMetaDicFromBookMarkMetaEntitys:(NSArray *)entityArrays {
    if (entityArrays == nil || entityArrays.count <= 0) {
        return nil;
    }
    NSMutableArray *dicArray = [[NSMutableArray alloc] init];
    for (NSManagedObject *entity in entityArrays) {
        if (entity == nil) {
            continue;
        }
    
        NSString *bookId = [entity valueForKey:@"bookId"];
        NSString *bookMarkId = [entity valueForKey:@"bookMarkId"];
        NSString *bookMarkName = [entity valueForKey:@"bookMarkName"];
        NSString *bookMarkType = [entity valueForKey:@"bookMarkType"];
        NSString *bookMarkContent = [entity valueForKey:@"bookMarkContent"];
        NSString *targetId = [entity valueForKey:@"targetId"];
        //日期转换
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        //
        NSDate *createBookMarkDate = [entity valueForKey:@"createBookMarkTime"];
        NSDate *updateBookMarkDate = [entity valueForKey:@"updateBookMarkTime"];
        NSString *createBookMarkTime = [dateFormatter stringFromDate:createBookMarkDate];
        NSString *updateBookMarkTime = [dateFormatter stringFromDate:updateBookMarkDate];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:bookId,@"book_id",bookMarkId,@"bookmark_id",bookMarkName,@"bookmark_name",bookMarkContent,@"bookmark_content",targetId,@"target_id",bookMarkType,@"type",createBookMarkTime,@"create_time",updateBookMarkTime,@"update_time", nil];
        [dicArray addObject:dic];
    }
    if (dicArray == nil || dicArray.count <= 0) {
        LogError (@"UserRecordDataManager - getBookMarkMetaDicFromBookMarkMetaEntitys:parse entity to dictionary failed ");
    }
    return dicArray;
}


//扫描二维码时，根据QR_map中的内容来更新progress
- (BOOL)updateBookMarkMetaProgressWithProgressInfo:(scanResultItem *)scanItem {
    BookMarkMetaManager *bookMarkMetaManager = [BookMarkMetaManager instance];
    return [bookMarkMetaManager updateBookMarkMetaProgressWithProgressInfo:scanItem];
}






#pragma mark -- collection
//保存“收藏”
- (BOOL)saveCollectionMeta:(CollectionMeta *)collectionMeta {
    CollectionMetaManager *manager = [CollectionMetaManager instance];
    BOOL ret = [manager saveCollectionMeta:collectionMeta];
    return ret;
}

//获取收藏列表，2.0版中，book_id一定不为空，type，quewryIds可能为空
- (NSArray *)getCollectionListWithInfoDic:(NSDictionary *)infoDic {
    //
    NSMutableArray *collctionListArr = [NSMutableArray array];
    CollectionMetaManager *manager = [CollectionMetaManager instance];
    
    NSString *bookId = [infoDic objectForKey:@"book_id"];
    NSString *collectionType = [infoDic objectForKey:@"type"];
    //进行二次解析
    NSString *queryIdsStr = [infoDic objectForKey:@"query_ids"];
        //queryIds为空
    if (queryIdsStr == nil || queryIdsStr.length <= 0) {
        NSArray *tempArr = [manager getCollectionMetaWith:bookId andcollectionType:collectionType andQueryId:nil];
        for (NSManagedObject *tempObjc in tempArr) {
            if (tempObjc == nil) {//为空，则不作处理
                continue;
            }
            [collctionListArr addObject:tempObjc];
        }
    }
    else {  //queryIds非空
        SBJsonParser *parse = [[SBJsonParser alloc] init];
        NSArray *queryIds = [parse objectWithString:queryIdsStr];
        //根据参数来查询收藏列表
        for (NSString *tempQueryId in queryIds) {
            NSArray *tempArr = [manager getCollectionMetaWith:bookId andcollectionType:collectionType andQueryId:tempQueryId];
            if (tempArr == nil || tempArr.count <= 0) {
                continue;
            }
            for (NSManagedObject *tempObjc in tempArr) {
                if (tempObjc == nil) {//为空，则不作处理
                    continue;
                }
                [collctionListArr addObject:tempObjc];
            }
        }
    }
    
    //
    //转换收集到的“收藏列表”，并返回收集到的“收藏列表”
    return [self parseCollectionDicWithCollectionArray:collctionListArr];
    
}

//获取所有的收藏列表
- (NSArray *)getAllCollectionList {
    
    CollectionMetaManager *manager = [CollectionMetaManager instance];
     NSArray *collectionListArr = [manager getAllCollectionMeta];
    //将获取到的entity转换成dic
    return [self parseCollectionDicWithCollectionArray:collectionListArr];
    
}



- (NSArray *)parseCollectionDicWithCollectionArray:(NSArray *)entityArrays {
   
    if (entityArrays == nil || entityArrays.count <= 0) {
        LogInfo(@"UserRecordDataManager - parseCollectionDicWithCollectionArray : parseCollectionDic failed because of entityArray is nil");
        return nil;
    }
     NSMutableArray *dicArr = [[NSMutableArray alloc] init];
    //
    for (NSManagedObject *entity in entityArrays) {
        if (entity == nil) {
            continue;
        }
        NSString *bookId = [entity valueForKey:@"bookId"];
        NSString *contentQueryId = [entity valueForKey:@"contentQueryId"];
        NSString *collectionType = [entity valueForKey:@"collectionType"];
        NSString *content = [entity valueForKey:@"content"];
        NSDate *createDate = [entity valueForKey:@"collectionCreateTime"];
        //日期转换
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *createTimeStr = [dateFormatter stringFromDate:createDate];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:bookId,@"book_id",contentQueryId,@"content_query_id",collectionType,@"type",content,@"content",createTimeStr,@"create_time", nil];
        [dicArr addObject:dic];
    }
    //
    if (dicArr == nil || dicArr.count <= 0) {
        LogError(@"UserRecordDataManager - parseCollectionDicWithCollectionArray :failed parse  entity to dic ");
    }
    return dicArr;
}



//删除“收藏”内容
- (BOOL)deleteCollectionMetaWithInfoDic:(NSDictionary *)infoDic {
    
    NSString *bookId = [infoDic objectForKey:@"book_id"];
    //进行二次解析
    NSString *queryIdsStr = [infoDic objectForKey:@"query_ids"];
    SBJsonParser *parse = [[SBJsonParser alloc] init];
    NSArray *queryIds = [parse objectWithString:queryIdsStr];
    //
    CollectionMetaManager *manager = [CollectionMetaManager instance];
    BOOL isDeleted = NO;
    for (NSString *tempQueryId in queryIds) {
        BOOL ret = [manager deleteCollectionMetaWithBookId:bookId andWithQueryId:tempQueryId];
        isDeleted = ret;
        if (ret == NO) {
            return ret;//删除“收藏”时，只要有一个删除失败就返回NO。
        }
    }
    return isDeleted;
}



@end
