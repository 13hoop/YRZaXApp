//
//  NSUserDefaultUtil.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/16.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultUtil : NSObject
//为了能够明确知道项目中在NSUserDefault存放了哪些内容，故写到一个方法中

//save && change user current study type
+ (BOOL)setCurStudyTypeWithType:(NSString *)studyType;
//get user current study type
+ (NSString *)getCurStudyType;

//save HTTP request response 存一下response ，里面是否有session？
+ (BOOL)saveHttpResponse:(id)response;

@end
