//
//  ErrorConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "ErrorConfig.h"

#import "PathUtil.h"



@interface ErrorConfig ()

@property (nonatomic, copy) NSString *errorDataRootDirName;
@property (nonatomic, copy) NSString *crashFilename;

@end



@implementation ErrorConfig

@synthesize errorDataRootDirName = _errorDataRootDirName;
@synthesize crashFilename = _crashFilename;
@synthesize crashFilepath = _crashFilepath;



#pragma mark - properties
- (NSString *)errorDataRootDirName {
    return @"error_report";
}

- (NSString *)crashFilename {
    return @"crash";
}

// crash file path
- (NSString *)crashFilepath {
    if (_crashFilepath == nil) {
        NSString *documentsPath = [PathUtil getDocumentsPath];
        _crashFilepath = [NSString stringWithFormat:@"%@/%@/%@", documentsPath, self.errorDataRootDirName, self.crashFilename];
    }
    
    {
        BOOL isDir = NO;
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:[_crashFilepath stringByDeletingLastPathComponent] isDirectory:&isDir];
        if (!(isDir && existed)) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_crashFilepath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return _crashFilepath;
}


#pragma mark - methods
// singleton
+ (ErrorConfig *)instance {
    static ErrorConfig *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


// web request params
- (NSString *)userAgent {
    return @"com.diyebook.ebooksystem.app.ios";
}

@end
