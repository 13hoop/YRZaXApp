//
//  DES3Util.h
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DES3Util : NSObject

#pragma mark - properties
// 密钥
@property (nonatomic, copy) NSString *key;
// 初始化矩阵
@property (nonatomic, copy) NSString *iv;


#pragma mark - methods
// init
- (DES3Util *)initWithKey:(NSString *)key andIV:(NSString *)iv;

// 加密方法
- (NSString*)encrypt:(NSString*)plainText;

// 解密方法
- (NSString*)decrypt:(NSString*)encryptText;

@end
