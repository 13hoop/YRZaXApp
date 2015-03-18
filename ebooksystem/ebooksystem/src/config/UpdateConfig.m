//
//  UpdateConfig.m
//  ebooksystem
//
//  Created by zhenghao on 10/29/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UpdateConfig.h"

#import "Config.h"


@implementation UpdateConfig

@synthesize urlForCheckUpdate = _urlForCheckUpdate;


#pragma mark - properties
// 检查更新的url
- (NSString *)urlForCheckUpdate {
    //    return [NSString stringWithFormat:@"http://s-115744.gotocdn.com:8296/index.php?c=apps_update_ctrl&m=get_update_info&appname=%@&channel=%@", [AppConfig instance].appNameForCheckUpdate, [AppConfig instance].channel];
    
    
//    return [NSString stringWithFormat:@"http://%@/index.php?c=apps_update_ctrl&m=get_update_info&appname=%@&channel=%@", [Config instance].appConfig.httpDomain, [AppConfig instance].appNameForCheckUpdate, [AppConfig instance].channel];
    return [NSString stringWithFormat:@"http://test.zaxue100.com/index.php?c=apps_update_ctrl&m=get_update_info&appname=zaxue_ios&channel=default"];
    
}


#pragma mark - methods
// singleton
+ (UpdateConfig *)instance {
    static UpdateConfig *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}




@end
