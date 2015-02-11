//
//  scanQRcodeDataManager.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/5.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>


//map 文件的内容
@interface scanResultItem : NSObject

@property (nonatomic, copy) NSString *bookIdInMap;
@property (nonatomic, copy) NSString *queryIdInMap;
@property (nonatomic, copy) NSString *pageTypeInMap;
@property (nonatomic, copy) NSString *descInMap;
@property (nonatomic, copy) NSString *pageArgsInMap;


@end

@interface scanQRcodeDataManager : NSObject

#pragma mark - singleton
+ (scanQRcodeDataManager *)instance;

#pragma mark - load knowledge



#pragma mark - get map data from shit by scanInfo
- (NSArray *)getMapDataByScanInfo:(NSString *)scanInfo;




    
    

@end
