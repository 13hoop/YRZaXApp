//
//  SecurityUtil.h
//  Smile
//
//  
//  Copyright (c) sanweishuku All rights reserved.
//


#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject 

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString *)input;
+ (NSString*)decodeBase64String:(NSString *)input;

+ (NSString*)encodeBase64Data:(NSData *)data;
+ (NSString*)decodeBase64Data:(NSData *)data;

#pragma mark - AES加密
//将string转成带密码的data
+ (NSString*)encryptAESData:(NSString*)string app_key:(NSString*)key ;
//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data app_key:(NSString*)key ;


//网上的方法
+(NSString *)AES128Encrypt:(NSString *)plainText andwithPassword:(NSString *)password;
+(NSString *)AES128Decrypt:(NSString *)encryptText andwithPassword:(NSString *)password;
@end
