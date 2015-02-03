//
//  DrawableConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/5/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "DrawableConfig.h"

@implementation DrawableConfig

@synthesize drawableRootPath = _drawableRootPath;

#pragma mark - properties
// drawable root path
- (NSString *)drawableRootPath {
    if (_drawableRootPath == nil) {
        _drawableRootPath = @"res/drawable";
    }
    
    return _drawableRootPath;
}

#pragma mark - singleton
+ (DrawableConfig *)instance {
    static DrawableConfig *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

// drawable's full path
- (NSString *)getImageFullPath:(NSString *)imageFileName {
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", self.drawableRootPath, imageFileName];
    return fullPath;
}


// startup image's full path
- (NSString *)getStartupImageFullPath:(NSString *)imageFileName {
    NSString *fullPath = [NSString stringWithFormat:@"%@/startup-page/%@", self.drawableRootPath, imageFileName];
    return fullPath;
}

// tabbar image's full path

- (NSString *)getTabbarItemImageFullPath:(NSString *)imageFileName {
    NSString *fullPath = [NSString stringWithFormat:@"%@/tabbarItem/%@", self.drawableRootPath, imageFileName];
    return fullPath;
}
@end
