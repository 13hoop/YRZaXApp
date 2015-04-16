//
//  CollectionEntity.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/9.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CollectionEntity : NSManagedObject

@property (nonatomic, retain) NSString * gUserId;
@property (nonatomic, retain) NSString * bookId;
@property (nonatomic, retain) NSString * contentQueryId;
@property (nonatomic, retain) NSString * collectionType;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * collectionCreateTime;
@property (nonatomic, retain) NSString * collectionDescInfo;
@property (nonatomic, retain) NSString * collectionId;

@end
