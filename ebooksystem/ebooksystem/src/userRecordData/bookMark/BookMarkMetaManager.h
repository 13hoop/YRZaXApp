//
//  BookMarkMetaManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/3.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMarkMeta.h"
#import "scanQRcodeDataManager.h"

@interface BookMarkMetaManager : NSObject

#pragma mark - singleton单例
+ (BookMarkMetaManager *)instance;

#pragma mark - add && sava bookMark meta
- (BOOL)saveBookMarkMeta:(BookMarkMeta *)bookMarkMeta;


#pragma mark - delete book Mark 
//delete book mark by bookId ,bookMarkId
- (BOOL)deleteBookMarkMetaWithBookId:(NSString *)bookId andBookMarkId:(NSString *)bookMarkId;


#pragma mark - getter
//get book mark by bookId , bookMarkId
- (NSArray *)getBookMarkMetaWithBookId:(NSString *)bookId andBookMarkId:(NSString *)bookMarkId;

//get book mark by bookId , bookMarkType ,queryId
- (NSArray *)getBookMarkMetaWithBookId:(NSString *)bookId andBookMarkType:(NSString *)bookMarkType andQueryId:(NSString *)queryId;

//get all book mark
- (NSArray *)getAllBookMark;

#pragma mark - setter

//update book mark with

- (BOOL)updateBookMarkMetaWithLatestBookMarkUpdateInfo:(NSDictionary *)updateDic;
//扫描二维码进到书中的某一页，需要更新进度，每本书只有一个BOOKMarkType为progress
- (BOOL)updateBookMarkMetaProgressWithProgressInfo:(scanResultItem *)scanItem;
@end
