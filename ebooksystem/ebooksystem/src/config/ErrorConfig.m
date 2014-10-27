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

@synthesize errorUrlByGet = _errorUrlByGet;
@synthesize errorUrlByPost = _errorUrlByPost;



#pragma mark - properties
- (NSString *)errorUrlByGet {
    // http://log.zaxue100.com/e.html?par1=**&par2=
//    return @"http://log.zaxue100.com/e.html?"; // online
    return @"http://118.244.235.155:8296/e.html?"; // offline
}

- (NSString *)errorUrlByPost {
//    return @"http://log.zaxue100.com/index.php?c=errorctrl&m=upload"; // online
    return @"http://118.244.235.155:8296/index.php?c=errorctrl&m=upload"; // offline
}

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
        NSString *parentPath = [_crashFilepath stringByDeletingLastPathComponent];
        BOOL isDir = NO;
        BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:parentPath isDirectory:&isDir];
        if (!(isDir && existed)) {
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
    }
    
    return _crashFilepath;
}

//- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
//                                                        message:message
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"退出", nil)
//                                              otherButtonTitles:nil];
//        
//        [alert show];
//    });
//}



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
