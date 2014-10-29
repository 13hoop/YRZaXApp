//
//  UpdateInfo.m
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UpdateInfo.h"

@implementation UpdateInfo

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqual:@"status"]) {
            return @"status";
        }
        else if ([keyName isEqual:@"msg"]) {
            return @"message";
        }
        else if ([keyName isEqual:@"version_code"]) {
            return @"appVersionCode";
        }
        else if ([keyName isEqual:@"version_name"]) {
            return @"appVersionStr";
        }
        else if ([keyName isEqual:@"version_url"]) {
            return @"appDownloadUrl";
        }
        else if ([keyName isEqual:@"version_desc"]) {
            return @"appVersionDesc";
        }
        else {
            return keyName;
        }
    }
                                          modelToJSONBlock:^NSString *(NSString *keyName) {
                                              if ([keyName isEqual:@"status"]) {
                                                  return @"status";
                                              }
                                              else if ([keyName isEqual:@"message"]) {
                                                  return @"msg";
                                              }
                                              else if ([keyName isEqual:@"appVersionCode"]) {
                                                  return @"version_code";
                                              }
                                              else if ([keyName isEqual:@"appVersionStr"]) {
                                                  return @"version_name";
                                              }
                                              else if ([keyName isEqual:@"appDownloadUrl"]) {
                                                  return @"version_url";
                                              }
                                              else if ([keyName isEqual:@"appVersionDesc"]) {
                                                  return @"version_desc";
                                              }
                                              else {
                                                  return keyName;
                                              }
                                          }];
}

@end
