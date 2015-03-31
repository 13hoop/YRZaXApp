//
//  NSUserDefaultUtil.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/1/16.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "NSUserDefaultUtil.h"
#import "Config.h"

@implementation NSUserDefaultUtil


//创建、修改用户当前的学习类型，参数是0,1,2...   key:curStudyType
+ (BOOL)setCurStudyTypeWithType:(NSString *)studyType {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:studyType forKey:@"curStudyType"];
    [userDefault synchronize];
    if ([[userDefault objectForKey:@"curStudyType"] isEqualToString:studyType]) {
        return YES;
    }
    else {
       return NO;
    }
}

//获取用户当前学习类型
+ (NSString *)getCurStudyType {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *curStudyType = [userDefault objectForKey:@"curStudyType"];
    if (curStudyType ==nil || curStudyType.length <= 0) {
        return nil;
    }
    return curStudyType;
}

//存http 请求的相应，为了获取里面的session，里面有session吗？
+ (BOOL)saveHttpResponse:(id)response {
    if (response == nil) {
        return NO;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:response forKey:@"response"];
    [userDefault synchronize];
    return YES;
}

#pragma mark 设置UA
+ (BOOL)setUserAgent {
    NSString *UAString = [Config instance].webConfig.userAgent;
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : UAString, @"User-Agent" : UAString}];
    return YES;
}

#pragma mark 储存error message
+ (BOOL)saveErrorMessage:(NSData *)errorMessage {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:errorMessage forKey:@"errorMessage"];
    [userdefault synchronize];
    return YES;
}

#pragma mark 储存设备的token
+ (BOOL)saveDeviceTokenStr:(NSData *)deviceToken {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:deviceToken forKey:@"deviceToken"];
    [userdefault synchronize];
    return YES;
}

+ (NSData *)getDeviceTokenStr {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSData *deviceStr = [userdefault objectForKey:@"deviceToken"];
    return deviceStr;
}


//
+ (BOOL)saveUpdateStatus:(NSString *)updateStatus {
    if (updateStatus == nil || updateStatus.length <= 0) {
        return NO;
    }
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:updateStatus forKey:@"updateStatus"];
    [userdefault synchronize];
    NSLog(@"我就想看看这个值存上了没有===%@",[userdefault objectForKey:@"updateStatus"]);
    return YES;
}

+ (NSString *)getUpdateStataus {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *updateStatus = [userdefault objectForKey:@"updateStatus"];
    return  updateStatus;
}

+ (BOOL)removeUpdateStatus {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"updateStatus"];
    [userDefault synchronize];
    return YES;
}


//夜间模式
+ (BOOL)setGlobalDataWithObject:(NSDictionary *)dic {
    //将页面传来的dic使用Key-value键值对形式存储,key（GlobalData）
    if (dic == nil) {
        return NO;
    }
    //先从nsuserDefault中查找是否已经存在具体的值
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *globalValueDic = [userDefaults objectForKey:@"GlobalData"];
    NSMutableDictionary *updateDic = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:@"GlobalData"]];
    if (globalValueDic == nil) {
        //本地没有数据，则直接保存
        [userDefaults setObject:dic forKey:@"GlobalData"];
        [userDefaults synchronize];
        //判断是否保存成功
        NSDictionary *dicExist =[userDefaults objectForKey:@"GlobalData"];
        if (dicExist) {//保存成功
            return YES;
        }
        else {
            return NO;
        }
    }
    //本地已经有global数据存储，则更新本地数据
    NSArray *keyArray = [dic allKeys];//获取页面新传来的dic中的所有的key
    NSArray *existedKeyArray = [globalValueDic allKeys];//获取已经存在dic中的key
    if (keyArray == nil || keyArray.count <= 0 || existedKeyArray == nil || existedKeyArray.count <= 0) {
        return NO;
    }
    for (NSString *tempKey in keyArray) {
        NSString *existedValue = [updateDic valueForKey:tempKey];//这样取会不会崩掉？
        NSString *updateValue = [dic valueForKey:tempKey];
        if (existedValue == nil || existedValue.length <= 0) {
            //原来数组中不存在这个字典，则添加
            [updateDic setObject:updateValue forKey:tempKey];//若是原dic中无当前key对应的value，则添加，若是已经存在则修改
        }
        else {
            //移除掉已经存在的数据
            [updateDic removeObjectForKey:tempKey];
            NSLog(@"%@",updateDic);
            //保存新的数据
            [updateDic setObject:updateValue forKey:tempKey];
            
        }
    }
    [userDefaults removeObjectForKey:@"GlobalData"];//移除原有的数据
    [userDefaults setValue:updateDic forKey:@"GlobalData"];//保存新的数据
    
    [userDefaults synchronize];
    return YES;
    
}

+ (NSDictionary *)getGlobalDataWithKeyArray:(NSArray *)keyArray {
    if (keyArray == nil || keyArray.count <= 0) {
        return nil;
    }
    
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults objectForKey:@"GlobalData"];
    for (NSString *tempKey in keyArray) {//遍历传来的数组，获取到对应value值，存到新的字典中
        if (tempKey == nil || tempKey.length <= 0) {
            continue;
        }
        NSString *tempValue = [dic objectForKey:tempKey];
        [mutableDic setValue:tempValue forKey:tempKey];
    }
    
    return mutableDic;
    
}

//获取当前的白天夜间模式,现在字典中只有一个字段
+ (NSString *)getGlobalMode {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults objectForKey:@"GlobalData"];
    NSString *modeString = [dic objectForKey:@"render-mode"];
    return modeString;
}






//存储文件移动的状态

+ (BOOL)saveMoveCompleteString {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"completed" forKey:@"MoveComplete"];
    [userDefault synchronize];
    return YES;
}

+ (NSString *)getMoveCompleteString {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *completeString = [userDefault objectForKey:@"MoveComplete"];
    return completeString;
}

+ (BOOL)removeMoveCompleteString {
     NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"MoveComplete"];
    [userDefault synchronize];
    return YES;
}
@end
