//
//  CRSA.m
//  OpenSSLRSAWrapper
//
//  Created by wanghaoyu on 14-10-12.
//  Copyright (c) 2014年 sban@netspectrum.com. All rights reserved.
//

#import "CRSA.h"
#define BUFFSIZE  1024
#import "GTMBase64.h"
#define PADDING RSA_PADDING_TYPE_PKCS1
@implementation CRSA

+(id)shareInstance
{
    static CRSA *_crsa = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _crsa = [[self alloc] init];
    });
    return _crsa;
}
-(BOOL)importRSAKeyWithType:(KeyType)type
{
    FILE *file;
    NSString *keyName = type == KeyTypePublic ? @"rsa_public_key" : @"rsa_private_key";
//    NSString *keyPath = [[NSBundle mainBundle] pathForResource:keyName ofType:@"pem"];
    NSString *keyPath=nil;
    if ([keyName isEqualToString:@"rsa_public_key"])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        keyPath=[NSString stringWithFormat:@"%@/KEYPEM/rsa_public_key.pem",path];
        
    }
    else
    {
        keyPath=[[NSBundle mainBundle] pathForResource:keyName ofType:@"pem"];
    }
    NSLog(@"piublicKeyPath==========%@",keyPath);
      
    file = fopen([keyPath UTF8String], "rb");
    
    if (NULL != file)
    {
        if (type == KeyTypePublic)
        {
            _rsa = PEM_read_RSA_PUBKEY(file, NULL, NULL, NULL);
            assert(_rsa != NULL);
           
        }
        else
        {
            _rsa = PEM_read_RSAPrivateKey(file, NULL, NULL, NULL);
            assert(_rsa != NULL);
        }
        
        fclose(file);
        
        return (_rsa != NULL) ? YES : NO;
    }
    
    return NO;
}
-(NSString *)encryptByRsa:(NSString *)content withKeyType:(KeyType)keyType
{
    if (![self importRSAKeyWithType:keyType])
        return nil;
    
    int status;
    int length  = [content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
    {
        input[i] = [content characterAtIndex:i];
    }
    
    NSInteger  flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING];
    
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    
    switch (keyType) {
        case KeyTypePublic:
            status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa, PADDING);
            
            break;
            
        default:
            status = RSA_private_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa, PADDING);
            break;
    }
    
    if (status)
    {
        NSData *returnData = [NSData dataWithBytes:encData length:status];
        free(encData);
        encData = NULL;
        
//        NSString *ret = [returnData base64EncodedString];
        NSString *ret=[GTMBase64 stringByEncodingData:returnData];
        
        return ret;
    }
    
    free(encData);
    encData = NULL;
    
    return nil;

}
-(NSString *)decryptByRsa:(NSString *)content withKeyType:(KeyType)keyType
{
    if (![self importRSAKeyWithType:keyType])
        return nil;
    
    int status;
    
//    NSData *data = [content base64DecodedData];
    NSData *data=[GTMBase64 decodeString:content];
    int length = [data length];
    
    NSInteger flen = [self getBlockSizeWithRSA_PADDING_TYPE:PADDING];
    char *decData = (char*)malloc(flen);
    bzero(decData, flen);
    
    switch (keyType) {
        case KeyTypePublic:
            status = RSA_public_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa, PADDING);
            break;
            
        default:
            status = RSA_private_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa, PADDING);
            break;
    }
    
    if (status)
    {
        NSMutableString *decryptString = [[NSMutableString alloc] initWithBytes:decData length:strlen(decData) encoding:NSASCIIStringEncoding];
        free(decData);
        decData = NULL;
        
        return decryptString;
    }
    
    free(decData);
    decData = NULL;
    
    return nil;
}
- (int)getBlockSizeWithRSA_PADDING_TYPE:(RSA_PADDING_TYPE)padding_type
{
    int len = RSA_size(_rsa);
    
    if (padding_type == RSA_PADDING_TYPE_PKCS1 || padding_type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}
-(void)generatersa_public_keyWithpublicString:(NSString *)publicKey
{
    //在libary下创建一个目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"documentsDirectory%@",documentsDirectory);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testDirectory = [documentsDirectory stringByAppendingPathComponent:@"KEYPEM"];
    // 创建目录
    [fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    //指定一个目录，用于存放公钥文件
    NSString *LibraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/KEYPEM/rsa_public_key.pem"];
    NSLog(@"LibraryPath===%@",LibraryPath);
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //将项目中的公钥转成NSData类型数据---这个是自己生成的证书中的公钥的路径吗？
    NSString *publicStr=@"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCeoNgBn3qxNyRVBXPeVZ2xM3w\nbtztB63l5vXNmIIPg0OO4lAp1tUkpcbeMpydGQfAI78V25l+3LQ4FoaoKJuzyCDa\noNKWOe7vdyUOS/8beC1+3VG8+/zoSo35k8KuY3aBDHK0+IUJEyCaTuAuXFeEICdj\neA+rJsToo4vvT9hyPwIDAQAB\n-----END PUBLIC KEY-----";
//    NSData *publickData=[GTMBase64 encodeData:[publicStr dataUsingEncoding:NSUTF8StringEncoding]];
    //写入文件不需要转码吧？
    NSData *publickData=[publicKey dataUsingEncoding:NSUTF8StringEncoding];
    if([fm fileExistsAtPath:LibraryPath])
    {
//        publickData = [NSData dataWithContentsOfFile:LibraryPath];
    }
    else
    {   //如果不存在，就将公钥字符串
        [publickData writeToFile:LibraryPath atomically:YES];
    }
    //        publickData = [GTMBase64 decodeData:publickData];
    NSLog(@"publicData=====%@",publickData);
    if(publickData == nil)
    {
        NSLog(@"Can not read from pub.pem");
    }
    
}
@end
