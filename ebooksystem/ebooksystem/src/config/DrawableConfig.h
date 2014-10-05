//
//  DrawableConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/5/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawableConfig : NSObject

#pragma mark - properties
// drawable images' root path
@property(nonatomic, copy) NSString *drawableRootPath;


#pragma mark - methods
// singleton
+ (DrawableConfig *)instance;

// drawable's full path
- (NSString *)getImageFullPath:(NSString *)imageFileName;

@end
