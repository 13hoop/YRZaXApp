//
//  StatisticsManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "StatisticsManager.h"

@implementation StatisticsManager

#pragma mark - singleton
+ (StatisticsManager *)instance {
    static StatisticsManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[StatisticsManager alloc] init];
    });
    
    return sharedInstance;

}

#pragma mark - statistics
- (BOOL)pageStatisticWithEvent:(NSString *)eventName andArgs:(NSDictionary *)args {
    if (eventName == nil || eventName.length <= 0) {
        return NO;
    }
    
    // todo: do statistics
    
//    JSONObject jsonObject = null;
//    HashMap<String, String> mapData = new HashMap<String, String>();
//    try {
//        
//        jsonObject = new JSONObject(args);
//        Iterator<String> it = jsonObject.keys();
//        String key;
//        String value;
//        while (it.hasNext()) {
//            key = it.next();
//            value = jsonObject.getString(key);
//            mapData.put(key, value);
//        }
//    } catch (Exception e) {
//        mapData.clear();
//    }
//    
//    if (mapData.isEmpty()) {
//        // 如果是空的map，证明统计的参数格式有错误，发送原始字符串到服务器
//        if (args != null && !args.equals("")) {
//            mapData.put("ORIGIN_STR", args);
//        } else {
//            mapData.put("ERROR_ARGS", "EMPTY");
//        }
//    }
//    
//    MobclickAgent.onEvent(getActivity(), eventName, mapData);
    
    return YES;
}

@end
