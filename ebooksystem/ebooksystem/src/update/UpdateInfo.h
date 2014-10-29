//
//  UpdateInfo.h
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "JSONModel.h"

@interface UpdateInfo : JSONModel

// 数据status
@property (nonatomic, copy) NSString *status; // 0: valid

// 是否有更新. "YES" or "NO"
@property (nonatomic, copy) NSString<Ignore> *shouldUpdate;

// message
@property (nonatomic, copy) NSString<Optional> *message;
// version code: 数字版本号, e.g, 1999
@property (nonatomic, copy) NSString<Optional> *appVersionCode;
// version str: 版本号, e.g, 1.0.0.1
@property (nonatomic, copy) NSString *appVersionStr;
// app download url
@property (nonatomic, copy) NSString<Optional> *appDownloadUrl;
// change log
@property (nonatomic, copy) NSString<Optional> *appVersionDesc;

@end
