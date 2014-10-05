//
//  NSData+AES.h
//  Smile
//
//Copyright (c) sanweishuku All rights reserved.
//



#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSString+Hashing.h"

#define gIv          @"0102030405060708" //可以自行修改

@implementation NSData (Encryption)

//(key和iv向量这里是16位的) 这里是CBC加密模式，安全性更高
//
- (NSData *)AES128EncryptWithKey:(NSString *)key {//加密
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    NSString *before16Key=[key substringToIndex:16];
    [before16Key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    NSString *mdIV=[key MD5Hash];
    NSLog(@"小写字母条件下进行MD5加密%@",mdIV);
    NSString *lowMdIV=[mdIV lowercaseString];
    NSLog(@"小写条件下进行MD5加密后得到的小写%@",lowMdIV);
    NSLog(@"小写状态下的前16位%@",[lowMdIV substringToIndex:16]);
    NSString *before16IV=[lowMdIV substringToIndex:16];
    
    [before16IV getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
    
    
    }


- (NSData *)AES128DecryptWithKey:(NSString *)key {//解密
    
    NSString *before16Key=[[key lowercaseString] substringToIndex:16];
    NSLog(@"解密使用的key,目的是为了看一下是否相同==%@",before16Key);
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [before16Key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    
    NSString *mdIV=[[[key lowercaseString] MD5Hash] lowercaseString];
    NSString *before16IV=[mdIV substringToIndex:16];
    
    [before16IV getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end
