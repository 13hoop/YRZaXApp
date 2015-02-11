//
//  CollectionMeta.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/7.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "CollectionMeta.h"
#import "CollectionEntity.h"
#import "UserManager.h"

@implementation CollectionMeta

@synthesize gUserId;
@synthesize bookId;
@synthesize contentQueryId;
@synthesize collectionType;
@synthesize content;
@synthesize collectionCreateTime;
@synthesize collectionDescInfo;
@synthesize collectionId;

//由CollectionEntity转为CollectionMeta
+ (CollectionMeta *)fromBookMarkEntity:(CollectionEntity *)bookMarkEntity {
    if (bookMarkEntity == nil) {
        return nil;
    }
    CollectionMeta *collectionMeta = [[CollectionMeta alloc] init];
    collectionMeta.gUserId = bookMarkEntity.gUserId;
    collectionMeta.bookId = bookMarkEntity.bookId;
    collectionMeta.contentQueryId = bookMarkEntity.contentQueryId;
    collectionMeta.collectionType = bookMarkEntity.collectionType;
    collectionMeta.content = bookMarkEntity.content;
    collectionMeta.collectionCreateTime = bookMarkEntity.collectionCreateTime;
    collectionMeta.collectionDescInfo = bookMarkEntity.collectionDescInfo;
    collectionMeta.collectionId = bookMarkEntity.collectionId;
    return collectionMeta;
}

//将CollectionMeta各属性赋予CollectionEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)collectionEntity {
    if (collectionEntity == nil) {
        return NO;
    }
    
    //gUserId -- 将collectionMeta添加到数据库时，每次都从本地取值，若是存在则存到数据库，反之将userId置为空
    UserManager *userManager = [UserManager instance];
    UserInfo *userinfo = [userManager getCurUser];
    NSString *gUserIdStr = userinfo.userId;
    
    //gUserId
    if (gUserIdStr == nil || gUserIdStr.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"gUserId"];
    }
    else {
        [collectionEntity setValue:gUserIdStr forKey:@"gUserId"];
    }
    
    //bookId
    if (self.bookId == nil || self.bookId.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"bookId"];
    }
    else {
        [collectionEntity setValue:self.bookId forKey:@"bookId"];
    }
    //contentQueryId
    if (self.contentQueryId == nil || self.contentQueryId.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"contentQueryId"];
    }
    else {
        [collectionEntity setValue:self.contentQueryId forKey:@"contentQueryId"];
    }
    //collectionType
    if (self.collectionType == nil || self.collectionType.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"collectionType"];
    }
    else {
        [collectionEntity setValue:self.collectionType forKey:@"collectionType"];
    }
    
    //content
    if (self.content == nil || self.content.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"content"];
    }
    else {
        [collectionEntity setValue:self.content forKey:@"content"];
    }
    
    //collectionCreateTime
    [collectionEntity setValue:[NSDate date] forKey:@"collectionCreateTime"];
    //collectionDescInfo --备用字段
    if (self.collectionDescInfo == nil || self.collectionDescInfo.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"collectionDescInfo"];
    }
    else {
        [collectionDescInfo setValue:self.collectionDescInfo forKey:@"collectionDescInfo"];
    }
    
    //collectionId -- 值唯一
    if (self.collectionId == nil || self.collectionId.length <= 0) {
        [collectionEntity setValue:@"" forKey:@"collectionId"];
    }
    else {
        [collectionEntity setValue:self.collectionId forKey:@"collectionId"];
    }
    
    return YES;
}


@end
