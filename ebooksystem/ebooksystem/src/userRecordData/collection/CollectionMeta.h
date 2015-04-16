//
//  CollectionMeta.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/7.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CollectionEntity;


@interface CollectionMeta : NSObject

@property (nonatomic,strong) NSString *gUserId;
@property (nonatomic,strong) NSString *bookId;
@property (nonatomic,strong) NSString *contentQueryId;
@property (nonatomic,strong) NSString *collectionType;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSDate *collectionCreateTime;
@property (nonatomic,strong) NSString *collectionDescInfo;
@property (nonatomic,strong) NSString *collectionId;

#pragma mark - 同collectionEntity转换
//由CollectionEntity转为CollectionMeta
+ (CollectionMeta *)fromBookMarkEntity:(CollectionEntity *)bookMarkEntity;

//将CollectionMeta各属性赋予CollectionEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)collectionEntity;




@end
