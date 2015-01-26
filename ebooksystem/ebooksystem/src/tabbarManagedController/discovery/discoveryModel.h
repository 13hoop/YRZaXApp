//
//  discoveryModel.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/25.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface discoveryModel : NSObject

- (NSDictionary *)getBookInfoWithDataIds:(NSArray *)dataIds;

@end
