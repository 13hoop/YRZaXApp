//
//  BookMarkMeta.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/3.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BookMarkEntity;



@interface BookMarkMeta : NSObject

@property (nonatomic,copy) NSString *bookId;
@property (nonatomic,copy) NSString *bookMarkId;
@property (nonatomic,copy) NSString *gUserId;
@property (nonatomic,copy) NSString *bookMarkName;
@property (nonatomic,copy) NSString *bookMarkContent;
@property (nonatomic,copy) NSString *targetId;
@property (nonatomic,copy) NSString *bookMarkType;
@property (nonatomic,copy) NSString *bookMarkDescInfo;
@property (nonatomic,copy) NSDate *createBookMarkTime;
@property (nonatomic,copy) NSDate *updateBookMarkTime;


#pragma mark - 同bookMarkEntity转换
//由bookMarkEntity转为bookMarkMeta
+ (BookMarkMeta *)fromBookMarkEntity:(BookMarkEntity *)bookMarkEntity;

//将bookMarkMeta各属性赋予bookMarkEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)bookMarkEntity;




@end
