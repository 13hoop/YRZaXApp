//
//  UserRecordDataManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/4.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMarkMeta.h"
#import "BookMarkMetaManager.h"

#import "CollectionMeta.h"
#import "CollectionMetaManager.h"
#import "scanQRcodeDataManager.h"



@interface UserRecordDataManager : NSObject

#pragma mark -- singleton单例
+ (UserRecordDataManager *)instance;

#pragma mark -- bookMark
//保存书签
- (BOOL)saveBookMarkMeta:(BookMarkMeta *)bookMarkMeta;

//删除书签
- (BOOL)deleteBookMarkMetaWithUpdateInfoDic:(NSDictionary *)updateDic;
//更新书签
- (BOOL)updateBookMarkMeta:(NSDictionary *)updateDic;
//获取书签
- (NSArray *)getBookMarkListWithBookId:(NSString *)bookId andBookType:(NSString *)bookType andQueryId:(NSString *)queryId;
//获取所有书签-- bookId为空时调用
- (NSArray *)getAllBookMark;
//二维码书签
- (BOOL)updateBookMarkMetaProgressWithProgressInfo:(scanResultItem *)scanItem;



#pragma mark -- collection
//保存“收藏”
- (BOOL)saveCollectionMeta:(CollectionMeta *)collectionMeta;

//获取“收藏”列表
- (NSArray *)getCollectionListWithInfoDic:(NSDictionary *)infoDic;

//获取所有的收藏列表
- (NSArray *)getAllCollectionList;

//删除“收藏”列表
- (BOOL)deleteCollectionMetaWithInfoDic:(NSDictionary *)infoDic;



@end
