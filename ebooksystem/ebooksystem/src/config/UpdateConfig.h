//
//  UpdateConfig.h
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateConfig : NSObject

// 检查更新的url
@property (nonatomic, copy, readonly) NSString *urlForCheckUpdate;


#pragma mark - methods
// singleton
+ (UpdateConfig *)instance;


@end
