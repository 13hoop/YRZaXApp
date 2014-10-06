//
//  PathUtil.m
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "PathUtil.h"

@implementation PathUtil

// 获取沙盒主目录路径
+ (NSString *)getHomePath {
    return NSHomeDirectory();
}

// 获取Documents目录路径
+ (NSString *)getDocumentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return  documentsPath;
}

// 获取Caches目录路径
+ (NSString *)getCachesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [paths objectAtIndex:0];
    return cachesPath;
}

// 获取tmp目录路径
+ (NSString *)getTempPath {
    return NSTemporaryDirectory();
}

// 获取app包路径
+  (NSString *)getBundlePath {
    return [[NSBundle mainBundle] resourcePath];
}


#pragma mark - copy data files
// 拷贝文件夹: fromPath => toPath
// 注: 此函数在拷贝时, 会将fromPath中的文件全部拷贝至toPath, 但toPath中原有的而在fromPath中没有的, 不会被覆盖
+ (BOOL)copyFilesFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    BOOL ret = YES;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:toPath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // prepare
    NSError *error = nil;
    
    NSArray *subDirsInAssets = [fileManager contentsOfDirectoryAtPath:fromPath error:&error];
    for (NSString *subDir in subDirsInAssets) {
        NSString *theFromPath = [NSString stringWithFormat:@"%@/%@", fromPath, subDir];
        NSString *theToPath = [NSString stringWithFormat:@"%@/%@", toPath, subDir];
        
        // remove old dir
        if ([[NSFileManager defaultManager] fileExistsAtPath:theToPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:theToPath error:nil];
        }
        
        // copy new dir
        NSError *copyError = nil;
        ret = [fileManager copyItemAtPath:theFromPath toPath:theToPath error:&copyError];
        if (!ret) {
            NSLog(@"Error copying files: %@", [copyError localizedDescription]);
        }
    }
    
    return ret;
}

@end
