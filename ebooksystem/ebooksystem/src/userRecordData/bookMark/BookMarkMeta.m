//
//  BookMarkMeta.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/3.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "BookMarkMeta.h"
#import "BookMarkEntity.h"
#import "UserManager.h"

@implementation BookMarkMeta

@synthesize bookId;
@synthesize bookMarkId;
@synthesize gUserId;
@synthesize bookMarkName;
@synthesize bookMarkContent;
@synthesize targetId;
@synthesize bookMarkType;
@synthesize bookMarkDescInfo;
@synthesize createBookMarkTime;
@synthesize updateBookMarkTime;

#pragma mark -同bookMarkEntity转换
+ (BookMarkMeta *)fromBookMarkEntity:(BookMarkEntity *)bookMarkEntity {
    
    if (bookMarkEntity == nil) {
        return nil;
    }
    
    BookMarkMeta *bookMeta = [[BookMarkMeta alloc] init];
    
    bookMeta.bookId = bookMarkEntity.bookId;
    //数据库中的bookMarkId为NSString类型，需要转成NSString类型
    bookMeta.bookMarkId = [NSString stringWithFormat:@"%@",bookMarkEntity.bookMarkId];
    bookMeta.gUserId = bookMarkEntity.gUserId;
    bookMeta.bookMarkName = bookMarkEntity.bookMarkName;
    bookMeta.bookMarkContent = bookMarkEntity.bookMarkContent;
    bookMeta.targetId = bookMarkEntity.targetId;
    bookMeta.bookMarkType = bookMarkEntity.bookMarkType;
    bookMeta.bookMarkDescInfo = bookMarkEntity.bookMarkDescInfo;
    bookMeta.createBookMarkTime = bookMarkEntity.createBookMarkTime;
    bookMeta.updateBookMarkTime = bookMarkEntity.updateBookMarkTime;
    
    return bookMeta;
    
}


//将bookMarkmeta的各属性赋值给bookMarkEntity
- (BOOL)setValuesForEntity:(NSManagedObject *)bookMarkEntity {
    if (bookMarkEntity == nil) {
        return NO;
    }
    //bookId
    if (self.bookId == nil || self.bookId.length <= 0 ) {
        [bookMarkEntity setValue:@"" forKey:@"bookId"];
    }
    else {
        [bookMarkEntity setValue:self.bookId forKey:@"bookId"];
    }
    
    //bookMarkId
    if (self.bookMarkId == nil || self.bookMarkId.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"bookMarkId"];
    }
    else {
        [bookMarkEntity setValue:self.bookMarkId forKey:@"bookMarkId"];
    }
    
//    //native自动分配bookMarkId，因为要返回给js这个UUID,所以UUID由外面传过来
//    NSString *UUID = [NSString stringWithFormat:@"%@", [UUIDUtil getUUID]];
//    [bookMarkEntity setValue:UUID forKey:@"bookMarkId"];
    
    //gUserId -- 将bookmark添加到数据库时，每次都从本地取值，若是存在则存到数据库，反之将userId置为空
    UserManager *userManager = [UserManager instance];
    UserInfo *userinfo = [userManager getCurUser];
    NSString *gUserIdStr = userinfo.userId;

    if (gUserIdStr == nil || gUserIdStr.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"gUserId"];
    }
    else {
        [bookMarkEntity setValue:gUserIdStr forKey:@"gUserId"];
    }
    //bookMarkName
    if (self.bookMarkName == nil || self.bookMarkName.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"bookMarkName"];
    }
    else {
        [bookMarkEntity setValue:self.bookMarkName forKey:@"bookMarkName"];
    }
    //bookMarkContent
    if (self.bookMarkContent == nil || self.bookMarkContent.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"bookMarkContent"];
    }
    else {
        [bookMarkEntity setValue:self.bookMarkContent forKey:@"bookMarkContent"];
    }
    //bookMarkDescInfo
    if (self.bookMarkDescInfo == nil || self.bookMarkDescInfo.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"bookMarkDescInfo"];
    }
    else {
        [bookMarkEntity setValue:self.bookMarkDescInfo forKey:@"bookMarkDescInfo"];
    }
    //bookMarkType
    if (self.bookMarkType == nil || self.bookMarkType.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"bookMarkType"];
    }
    else {
        [bookMarkEntity setValue:self.bookMarkType forKey:@"bookMarkType"];
    }
    //targetId
    if (self.targetId == nil || self.targetId.length <= 0) {
        [bookMarkEntity setValue:@"" forKey:@"targetId"];
    }
    else {
        [bookMarkEntity setValue:self.targetId forKey:@"targetId"];
    }
    //createBookMarkTime
    [bookMarkEntity setValue:[NSDate date] forKey:@"createBookMarkTime"];
    //updateBookMarkTime
    [bookMarkEntity setValue:self.updateBookMarkTime forKey:@"updateBookMarkTime"];
    
    
    return YES;
}


@end
