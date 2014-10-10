//
//  DES3Util.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//


#import "DES3Util.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"


@implementation DES3Util

// init
- (DES3Util *)initWithKey:(NSString *)key andIV:(NSString *)iv {
    self.key = key;
    self.iv = iv;
    
    return self;
}

// 加密方法
- (NSString*)encrypt:(NSString*)plainText {
    if (self.key == nil || self.key.length <= 0 || self.iv == nil || self.iv.length <= 0) {
        return nil;
    }
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
	size_t plainTextBufferSize = [data length];
	const void *vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
//    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [self.key UTF8String];
    const void *vinitVec = (const void *) [self.iv UTF8String];
    
//    ccStatus = CCCrypt(kCCEncrypt,
//                       kCCAlgorithm3DES,
//                       kCCOptionPKCS7Padding,
//                       vkey,
//                       kCCKeySize3DES,
//                       vinitVec,
//                       vplainText,
//                       plainTextBufferSize,
//                       (void *)bufferPtr,
//                       bufferPtrSize,
//                       &movedBytes);
    
    // kCCAlgorithmAES128
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeAES128,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
	NSString *result = [GTMBase64 stringByEncodingData:myData];
    return result;
}

// 解密方法
- (NSString*)decrypt:(NSString*)encryptText {
    if (self.key == nil || self.key.length <= 0 || self.iv == nil || self.iv.length <= 0) {
        return nil;
    }
    
    NSData *encryptData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
	size_t plainTextBufferSize = [encryptData length];

	const void *vplainText = [encryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
//    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *) [self.key UTF8String];
    const void *vinitVec = (const void *) [self.iv UTF8String];
    
    // kCCAlgorithm3DES
//    ccStatus = CCCrypt(kCCDecrypt,
//                       kCCAlgorithm3DES,
//                       kCCOptionPKCS7Padding,
//                       vkey,
//                       kCCKeySize3DES,
//                       vinitVec,
//                       vplainText,
//                       plainTextBufferSize,
//                       (void *)bufferPtr,
//                       bufferPtrSize,
//                       &movedBytes);

    // kCCAlgorithmAES128
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeAES128,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)bufferPtrSize];
    NSString *tmp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    
    return result;
}

@end
