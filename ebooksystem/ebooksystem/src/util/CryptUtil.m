//
//  DES3Util.m
//  ebooksystem
//
//  Created by zhenghao on 10/10/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//


#import "CryptUtil.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"


@implementation CryptUtil

// init
- (CryptUtil *)initWithKey:(NSString *)key andIV:(NSString *)iv {
    self.key = key;
    self.iv = iv;
    
    return self;
}

// 加密方法
- (NSString*)encryptAES128:(NSString*)plainText {
    if (self.key == nil || self.key.length <= 0 || self.iv == nil || self.iv.length <= 0) {
        return nil;
    }
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
	size_t plainTextSize = [data length];
//	const void *vplainText = (const void *)[data bytes];
    
    // 构造待加密字节数组
    uint8_t *plainTextBuffer = NULL;
    size_t numBytesToCrypt = 0;
    {
        int diff = kCCKeySizeAES128 - (plainTextSize % kCCKeySizeAES128);
        if (diff > 0) {
            numBytesToCrypt = plainTextSize + diff;
        }
        
        // 拷贝plain text
        plainTextBuffer = malloc(numBytesToCrypt);
        memset(plainTextBuffer, 0, numBytesToCrypt);
        memcpy(plainTextBuffer, [data bytes], plainTextSize);

        // 补0
        for (int i = 0; i < diff; i++) {
            plainTextBuffer[i + plainTextSize] = 0x00;
        }
    }
    
    // 构造输出字节数组
    size_t encryptedBufferSize = numBytesToCrypt + kCCBlockSizeAES128;
    uint8_t *encryptedBuffer = malloc(encryptedBufferSize);
    memset(encryptedBuffer, 0, encryptedBufferSize);
    
    size_t numBytesCrypted = 0;
    
    // key, iv
    const void *vkey = (const void *) [self.key UTF8String];
    const void *vinitVec = (const void *) [self.iv UTF8String];
    
    // kCCAlgorithmAES128
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmAES128,
                       0x0000, // no padding
//                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeAES128,
                       vinitVec,
                       plainTextBuffer,
                       numBytesToCrypt,
                       (void *)encryptedBuffer,
                       encryptedBufferSize,
                       &numBytesCrypted);
    
    NSString *result = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *myData = [NSData dataWithBytes:(const void *)encryptedBuffer length:(NSUInteger)numBytesCrypted];
        result = [GTMBase64 stringByEncodingData:myData];
    }
    
    free(plainTextBuffer);
    free(encryptedBuffer);
    return result;
}

// 解密方法
- (NSString*)decryptAES128:(NSString*)encryptText {
    if (self.key == nil || self.key.length <= 0 || self.iv == nil || self.iv.length <= 0) {
        return nil;
    }
    
    // 加密buffer
    NSData *encryptedData = [GTMBase64 decodeData:[encryptText dataUsingEncoding:NSUTF8StringEncoding]];
	size_t encryptedBufferSize = [encryptedData length];
	const void *encryptedBuffer = [encryptedData bytes];
    
    // 解密buffer
    size_t decryptedBufferSize = (encryptedBufferSize + kCCBlockSizeAES128) & ~(kCCBlockSizeAES128 - 1);
    uint8_t *decryptedBuffer = malloc( decryptedBufferSize * sizeof(uint8_t));
    memset((void *)decryptedBuffer, 0x0, decryptedBufferSize);
    size_t numBytesDecrypted = 0;
    
    // key, iv
    const void *vkey = (const void *) [self.key UTF8String];
    const void *vinitVec = (const void *) [self.iv UTF8String];
    
    // kCCAlgorithmAES128
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmAES128,
                       0x00, // no padding
//                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeAES128,
                       vinitVec,
                       encryptedBuffer,
                       encryptedBufferSize,
                       (void *)decryptedBuffer,
                       decryptedBufferSize,
                       &numBytesDecrypted);
    
    NSString *result = nil;
    if (cryptStatus == kCCSuccess) {
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)decryptedBuffer length:(NSUInteger)numBytesDecrypted] encoding:NSUTF8StringEncoding];
    }
    
    free(decryptedBuffer);
    
    return result;
}

@end
