//
//  ErrorInfo.m
//  ebooksystem
//
//  Created by zhenghao on 10/24/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "ErrorInfo.h"

@implementation ErrorInfo

#pragma mark - error
@synthesize errorName;
@synthesize errorType;
@synthesize errorDesc;

#pragma mark - device
@synthesize model;
@synthesize systemName;
@synthesize systemVersion;
@synthesize identifierForVendor;

#pragma mark - bundle
@synthesize bundleDisplayName;
@synthesize bundleShortVersion;
@synthesize bundleVersion;

#pragma mark - stack
@synthesize stack;

#pragma mark - NSException
@synthesize exception;



#pragma mark - methods
+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"error_name"]) {
            return @"errorName";
        }
        else if ([keyName isEqual:@"error_type"]) {
            return @"errorType";
        }
        else if ([keyName isEqual:@"error_desc"]) {
            return @"errorDesc";
        }
        else if ([keyName isEqual:@"model"]) {
            return @"model";
        }
        else if ([keyName isEqual:@"system_name"]) {
            return @"systemName";
        }
        else if ([keyName isEqual:@"system_version"]) {
            return @"systemVersion";
        }
        else if ([keyName isEqual:@"identifier_for_vendor"]) {
            return @"identifierForVendor";
        }
        else if ([keyName isEqual:@"bundle_display_name"]) {
            return @"bundleDisplayName";
        }
        else if ([keyName isEqual:@"bundle_hort_ersion"]) {
            return @"bundleShortVersion";
        }
        else if ([keyName isEqual:@"bundle_version"]) {
            return @"bundleVersion";
        }
        else if ([keyName isEqual:@"stack"]) {
            return @"stack";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"errorName"]) {
                                                  return @"error_name";
                                              }
                                              else if ([keyName isEqual:@"errorType"]) {
                                                  return @"error_type";
                                              }
                                              else if ([keyName isEqual:@"errorDesc"]) {
                                                  return @"error_desc";
                                              }
                                              else if ([keyName isEqual:@"model"]) {
                                                  return @"model";
                                              }
                                              else if ([keyName isEqual:@"systemName"]) {
                                                  return @"system_name";
                                              }
                                              else if ([keyName isEqual:@"systemVersion"]) {
                                                  return @"system_version";
                                              }
                                              else if ([keyName isEqual:@"identifierForVendor"]) {
                                                  return @"identifier_for_vendor";
                                              }
                                              else if ([keyName isEqual:@"bundleDisplayName"]) {
                                                  return @"bundle_display_name";
                                              }
                                              else if ([keyName isEqual:@"bundleShortVersion"]) {
                                                  return @"bundle_hort_ersion";
                                              }
                                              else if ([keyName isEqual:@"bundleVersion"]) {
                                                  return @"bundle_version";
                                              }
                                              else if ([keyName isEqual:@"stack"]) {
                                                  return @"stack";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end
