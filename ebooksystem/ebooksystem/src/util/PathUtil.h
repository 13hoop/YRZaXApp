//
//  PathUtil.h
//  ebooksystem
//
//  Created by zhenghao on 10/6/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathUtil : NSObject

// 获取沙盒主目录路径
+ (NSString *)getHomePath;

// 获取Documents目录路径
+ (NSString *)getDocumentsPath;

// 获取Caches目录路径
+ (NSString *)getCachesPath;

// 获取tmp目录路径
+ (NSString *)getTempPath;

// 获取app包路径
+  (NSString *)getBundlePath;

// 拷贝文件夹: fromPath => toPath
// 注: 此函数在拷贝时, 会将fromPath中的文件全部拷贝至toPath, 但toPath中原有的而在fromPath中没有的, 不会被覆盖
+ (BOOL)copyFilesFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

// 删除文件夹
+ (BOOL)deletePath:(NSString *)filePath;

@end
