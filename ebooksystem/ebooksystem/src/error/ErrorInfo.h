//
//  ErrorInfo.h
//  ebooksystem
//
//  Created by zhenghao on 10/24/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONModel.h"



@interface ErrorInfo : JSONModel

#pragma mark - error
@property (nonatomic, copy) NSString *errorName;
@property (nonatomic, copy) NSString *errorType;
@property (nonatomic, copy) NSString *errorDesc;

#pragma mark - device
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *systemName;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *identifierForVendor;

#pragma mark - bundle
@property (nonatomic, copy) NSString *bundleDisplayName;
@property (nonatomic, copy) NSString *bundleShortVersion; // e.g, 1.0.0
@property (nonatomic, copy) NSString *bundleVersion; // build version

#pragma mark - stack
@property (nonatomic, copy) NSArray *stack;

#pragma mark - NSException
@property (nonatomic, copy) NSException<Ignore> *exception;

@end
