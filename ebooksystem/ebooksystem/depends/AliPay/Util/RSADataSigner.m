//
//  RSADataSigner.m
//  SafepayService
//
//  Created by wenbi on 11-4-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RSADataSigner.h"
#import "openssl_wrapper.h"
#import "NSDataEx.h"

@implementation RSADataSigner

- (id)initWithPrivateKey:(NSString *)privateKey {
	if (self = [super init]) {
		_privateKey = [privateKey copy];
	}
	return self;
}

- (NSString*)urlEncodedString:(NSString *)string
{
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
}

//将私钥字符串中的特殊字符“\n”和“\r”去掉，然后再拼接成指定格式的私钥--自己写
- (NSString *)formatPrivateKey:(NSString *)privateKey {
    const char *pstr = [privateKey UTF8String];
    int len = [privateKey length];
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"-----BEGIN PRIVATE KEY-----\n"];
    int index = 0;
	int count = 0;
    while (index < len) {
        char ch = pstr[index];
		if (ch == '\r' || ch == '\n') {
			++index;
			continue;
		}
        [result appendFormat:@"%c", ch];
        if (++count == 79)
        {
            [result appendString:@"\n"];
			count = 0;
        }
        index++;
    }
    [result appendString:@"\n-----END PRIVATE KEY-----"];
    NSLog(@"私钥是======%@",result);
    return result;
}

- (NSString *)algorithmName {
	return @"RSA";
}

//该签名方法仅供参考,外部商户可用自己方法替换
- (NSString *)signString:(NSString *)string {
	
	//在Document文件夹下创建私钥文件
	NSString * signedString = nil;
	NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *path = [documentPath stringByAppendingPathComponent:@"AlixPay-RSAPrivateKey"];
//    NSLog(@"私钥存放在这个路径下：%@",path);
	//
	// 把密钥写入文件
	//
	NSString *formatKey = [self formatPrivateKey:_privateKey];//把密钥转换成一个字符串
	[formatKey writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];//写入到文件中
	
	const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
	unsigned int sig_len;
    //c的方法，这里讲到的签名是：
    int ret = rsa_sign_with_private_key_pem((char *)message, messageLength, sig, &sig_len, (char *)[path UTF8String]);
	//签名成功,需要给签名字符串base64编码和UrlEncode,该两个方法也可以根据情况替换为自己函数
    if (ret == 1) {
        NSString * base64String = base64StringFromData([NSData dataWithBytes:sig length:sig_len]);
		//NSData * UTF8Data = [base64String dataUsingEncoding:NSUTF8StringEncoding];
		signedString = [self urlEncodedString:base64String];
    }
	
	free(sig);
    return signedString;
}

@end
