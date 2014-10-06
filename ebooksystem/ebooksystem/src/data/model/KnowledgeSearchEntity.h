//
//  KnowledgeSearchEntity.h
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KnowledgeSearchEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * pkId;
@property (nonatomic, retain) NSString * searchId;
@property (nonatomic, retain) NSString * dataId;
@property (nonatomic, retain) NSString * dataNameEn;
@property (nonatomic, retain) NSString * dataNameCh;

@end
