//
//  IADownloadOperation.m
//  DownloadManager
//
//  Created by Omar on 8/2/13.
//  Copyright (c) 2013 InfusionApps. All rights reserved.
//

#import "IADownloadOperation.h"
#import "AFNetworking.h"
#import "IACacheManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation IADownloadOperation
{
    BOOL executing;
    BOOL cancelled;
    BOOL finished;
    NSString *_tempFilePath;
    NSString *_finalFilePath;
}

//下载在operation层上的实现
+ (IADownloadOperation*) downloadingOperationWithURL:(NSURL*)url
                                            useCache:(BOOL)useCache
                                            filePath:(NSString *)filePath
                                       progressBlock:(IAProgressBlock)progressBlock
                                     completionBlock:(IACompletionBlock)completionBlock
{
    //声明一个局部变量
    unsigned long long downloadedBytes = 0;
    
    IADownloadOperation *op = [IADownloadOperation new];
    op.url = url;
    //这里的filePath是我们调用下载方法时一层一层传过来的参数。
    op->_finalFilePath = filePath;
 
    if(useCache && [self hasCacheForURL:url])
    {
        [op fetchItemFromCacheForURL:url progressBlock:progressBlock
                       completionBlock:completionBlock];
        return nil;
    }
    //url也是我们传过来的url参数。
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //这是自己修改的内容---目的实现断点续传，源代码：没有第二句，上面的解开注释
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPRequestOperation *operation =nil;
    if (filePath)
    {
        //生成临时存储地址
        
//        NSString *fname = [NSString stringWithFormat:@"tempDownload%d", arc4random_uniform(INT_MAX)];
//        op->_tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fname];
        //生成固定的tempfilePath
        
        NSString *md5URLString = [self md5StringForString1:filePath];
        op->_tempFilePath = [[self cacheFolder1] stringByAppendingPathComponent:md5URLString];
        
        BOOL isResuming = NO;
        //判断临时存储地址下是否有文件存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:op->_tempFilePath])
        {
//            [[NSFileManager defaultManager] removeItemAtPath:op->_tempFilePath error:nil];
            
            downloadedBytes = [self fileSizeForPath:op->_tempFilePath];
            if (downloadedBytes>0) {
//                downloadedBytes--;
                //这是自己修改的内容---目的实现断点续传
                NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
                NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
                [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
                request = mutableURLRequest;
                operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            }
            isResuming = YES;
    }
    else
    {
            [[NSFileManager defaultManager] removeItemAtPath:op->_tempFilePath error:nil];
            operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
    }
        // 在指定地址试图创建一个文件(tempfile)
        if (!isResuming) {
            int fileDescriptor = open([op->_tempFilePath UTF8String], O_CREAT | O_EXCL | O_RDWR, 0666);
            if (fileDescriptor > 0) close(fileDescriptor);
        }
        
        //自己写，捕获异常--类似java中的异常机制，并打印导致异常原因。
        @try{
            //isResuming是一个很重要的参数，实现断点续传必须要设置参数为YES
            operation.outputStream = [[NSOutputStream alloc] initToFileAtPath:op->_tempFilePath append:isResuming];
        }
        @catch(NSException *exception) {
            NSLog(@"exception:%@", exception);
        }
        @finally {
            
        }
        
    }
    op.operation = operation;
    
    //(1)、请求成功的回调和失败的回调都在这里设置。参数是AFNetWorking库中传过来的。
    __weak IADownloadOperation *weakOp = op;
    //这个operation是AFHTTPRequestOperation，代理方法是AFNetworking第三方库的回调方法。就是一个block，{}中的代码会在触发后执行。
    //这个block触发的次数（or时机）：这个下载完成的block，包含两个模块：（1）success模块 （2）failue模块
    [op.operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         //调用 下面的 setCacheWithData方法,作用是？？
         [IADownloadOperation setCacheWithData:responseObject url:url];
         __strong IADownloadOperation *StrongOp = weakOp;
         if(StrongOp != nil && StrongOp->_tempFilePath && StrongOp->_finalFilePath)
         {
             NSError *error = nil;
             //（1）首先移除掉最终目录下已经存在的内容（如果不移除，新下载的内容无法写入），（2）然后将临时目录下的文件存储到到最终路径下
             [[NSFileManager defaultManager] removeItemAtPath:StrongOp->_finalFilePath error:&error];
             [[NSFileManager defaultManager] moveItemAtPath:StrongOp->_tempFilePath toPath:StrongOp->_finalFilePath error:&error];
         }
         [StrongOp finish];
         completionBlock(YES, responseObject);
         
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         __strong IADownloadOperation *StrongOp = weakOp;
         //怎样执行？？
         completionBlock(NO, nil);
         [StrongOp finish];
     }];
    
    /*(2)、设置progess的内容在这里，我们可以知道三个字段
          bytesRead  这个block方法最后一次被调用到这次被调用这个过程所读取的字节数。
          totalBytesRead 这个参数是相对于本次request而言的，在这个请求中已经读取的字节数。
          totalBytesExpectedToRead 本次请求预计要读取的字节数。
     */
    
         [op.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
         
         float progress;
         
         if (totalBytesExpectedToRead == -1)
         {
             progress = -32;
         }
         else
         {
             progress = (double)(totalBytesRead + downloadedBytes) / (double) (totalBytesExpectedToRead + downloadedBytes);
         }
             
             progressBlock(progress, url);
                 

        
     }];
    
    return op;
}


//用到的文件的地址：
+ (NSString *)cacheFolder1 {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kAFNetworkingIncompleteDownloadFolderName];
    }
    
    // ensure all cache directories are there
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

//MD5加密
+ (NSString *)md5StringForString1:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint32_t)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}
//
+ (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}







//这是写好的方法，在manager中调用
- (void)start
{
    NSLog(@"opeartion for <%@> started.", _url);
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    //要进行断点续传需要能够知道两点：（1）、找到暂时存放未下完的内容的目录 （2）、设置request的headField。
    [self.operation start];
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

+ (BOOL)hasCacheForURL:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    return [IACacheManager hasObjectForKey:encodeKey];
}

- (void)fetchItemFromCacheForURL:(NSURL*)url
                   progressBlock:(IAProgressBlock)progressBlock
                 completionBlock:(IACompletionBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *encodeKey = [IADownloadOperation cacheKeyForUrl:url];
        NSData *data = [IACacheManager objectForKey:encodeKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            progressBlock(1, url);
            completionBlock(YES, data);
            
            [self finish];
            
        });
    });
}

+ (void)setCacheWithData:(NSData*)data
                     url:(NSURL*)url
{
    NSString *encodeKey = [self cacheKeyForUrl:url];
    [IACacheManager setObject:data forKey:encodeKey];
}

+ (NSString*)cacheKeyForUrl:(NSURL*)url
{
    if (url == nil) {
        return nil;
    }
    
    NSString *key = url.absoluteString;
    const char *str = [key UTF8String];
    unsigned char r[16];
    CC_MD5(str, (uint32_t)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

- (void)startOperation
{
    [self.operation start];
    executing = YES;
}

- (void)stop
{
    //这个operation是AFHTTPRequestOperation的实例，这个方法也是IADownload封装的。
    [self.operation cancel];
    cancelled = YES;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isCancelled
{
    return cancelled;
}

- (BOOL)isFinished
{
    return finished;
}

@end
