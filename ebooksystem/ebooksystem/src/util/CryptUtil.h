//
//  DES3Util.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptUtil : NSObject

#pragma mark - properties
// 密钥
@property (nonatomic, copy) NSString *key;
// 初始化矩阵
@property (nonatomic, copy) NSString *iv;


#pragma mark - methods
// init
- (CryptUtil *)initWithKey:(NSString *)key andIV:(NSString *)iv;

// 加密方法
- (NSString*)encryptAES128:(NSString*)plainText;

// 解密方法
- (NSString*)decryptAES128:(NSString*)encryptText;

@end
