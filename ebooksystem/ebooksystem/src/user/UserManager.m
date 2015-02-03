//
//  UserManager.m
//  ebooksystem
//
//  Created by zhenghao on 10/9/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "UserManager.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "SBJson.h"
#import "SecurityUtil.h"
#import "UIDevice+IdentifierAddition.h"
#import "SecurityUtil.h"
#import "DeviceUtil.h"
#import "LogUtil.h"
@interface UserManager()
{
    NSUInteger index;
    NSUInteger rindex;
}

@end

@implementation UserManager

#pragma mark - singleton
+ (UserManager *)instance {
    static UserManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[UserManager alloc] init];
    });
    
    return sharedInstance;

}
+(UserManager*)shareInstance
{
    static UserManager *sharedInstance = nil;
    @synchronized (self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance=[[UserManager alloc] init];
        }
    }
    return sharedInstance;

}
#pragma mark - user related methods
// get default user
+ (UserInfo *)getDefaultUser {
    UserInfo *userInfo = [[UserInfo alloc] init];
    userInfo.username = @"defaultuser";
    userInfo.password = @"defaultpwd";
    userInfo.userId = @"";
    userInfo.balance = @"";
    
    return userInfo;
}

// get cur user  for 2.0
- (UserInfo *)getCurUser {
    UserInfo *userInfo = [[UserInfo alloc] init];
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    userInfo.username=[userDefault objectForKey:@"userInfoName"];
    userInfo.password=[userDefault objectForKey:@"userinfoPassword"];
    userInfo.userId=[userDefault objectForKey:@"userId"];
    userInfo.balance=[userDefault objectForKey:@"userInfoBalance"];
    userInfo.phoneNumber = [userDefault objectForKey:@"userInfoPhone"];
    userInfo.sessionId = [userDefault objectForKey:@"userInfoSessionId"];
    return userInfo;
}
//save userInfo for 2.0
-(BOOL)saveUserInfo:(UserInfo *)userinfo {
    if (userinfo == NULL) {
        return NO;
    }
    
    //先遍历数组，判断用户信息已经存在
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    [tempArr addObjectsFromArray:[userDefault objectForKey:@"usedUserArray"]];
    //判断用户是否已经存在，若存在获取他所在数组中的下标
    
    for (int i = 0; i < tempArr.count; i++) {
        
        NSDictionary *userInfoDic = [tempArr objectAtIndex:i];
        
        if ([[userInfoDic objectForKey:@"userId"] isEqualToString:userinfo.userId]) {
            //若是用户信息已经存在，则更新
            //1 先取到原先的数据中的用户名和余额
            NSString *originUserName = [userInfoDic objectForKey:@"userInfoName"];
            NSString *originBalance = [userInfoDic objectForKey:@"userInfoBalance"];
            NSString *originPhone = [userInfoDic objectForKey:@"userInfoPhone"];
            NSString *originSessionId = [userInfoDic objectForKey:@"userInfoSessionId"];
            //移除
            [tempArr removeObjectAtIndex:i];
            //2 js每次传过来的userInfo中不一定都有值，只有userId始终非空，name和balance可能为空。
            NSString *userId = userinfo.userId;
            NSString *curUserName = userinfo.username;
            NSString *curBalance = userinfo.balance;
            NSString *curPhone = userinfo.phoneNumber;
            NSString *cruSessionId = userinfo.sessionId;
            NSString *needSaveUserName = nil;
            NSString *needSaveBalance = nil;
            NSString *needSavePhone = nil;
            NSString *needSaveSessionId = nil;
            //3 判断是否为空
            if (curUserName == nil || curUserName.length <= 0) {
                needSaveUserName = originUserName;//保存之前的用户名
            }
            else {
                needSaveUserName = curUserName;
            }
            
            if (curBalance == nil || curBalance.length <= 0) {
                needSaveBalance = originBalance;//保存之前的余额
            }
            else {
                needSaveBalance = curBalance;
            }
            
            if (curPhone == nil || curPhone.length <= 0) {
                needSavePhone = originPhone;//保存之前的手机号
            }
            else {
                needSavePhone = curPhone;
            }
            
            if (cruSessionId == nil || cruSessionId.length <= 0) {
                needSaveSessionId = originSessionId;//保存之前的sessionId
            }
            else {
                needSaveSessionId = cruSessionId;
            }
            
            //4 将最新信息存成字典
            NSDictionary *userInfoDic=@{@"userInfoName":needSaveUserName,@"userinfoPassword":userinfo.password,@"userId":userinfo.userId,@"userInfoBalance":needSaveBalance,@"userInfoPhone":needSavePhone,@"userInfoSessionId":needSaveSessionId};
            //加到字典中
            [tempArr addObject:userInfoDic];
            //移除本地的老数据
            [userDefault removeObjectForKey:@"usedUserArray"];
            //save新的数据
            [userDefault setObject:tempArr forKey:@"usedUserArray"];
            [userDefault synchronize];
            
            //5 设置当前用户
            //userInfoName userinfoPassword userId userInfoBalance  nsuserdefault userInfoPhone 中存当前用户字段
            {
                NSUserDefaults *cruUserDefault = [NSUserDefaults standardUserDefaults];
                [cruUserDefault setObject:needSaveUserName forKey:@"userInfoName"];
                [cruUserDefault setObject:needSaveBalance forKey:@"userInfoBalance"];
                [cruUserDefault setObject:userId forKey:@"userId"];
                [cruUserDefault setObject:userinfo.password forKey:@"userinfoPassword"];
                [cruUserDefault setObject:needSavePhone forKey:@"userInfoPhone"];
                [cruUserDefault setObject:needSaveSessionId forKey:@"userInfoSessionId"];
                [cruUserDefault synchronize];
            }
            return YES;
        }
        
    }
    
    
    {
        NSString *userId = userinfo.userId;
        NSString *curUserName = userinfo.username;
        NSString *curBalance = userinfo.balance;
        NSString *curPhone = userinfo.phoneNumber;
        NSString *cruSessionId = userinfo.sessionId;
        NSString *needSaveUserName = nil;
        NSString *needSaveBalance = nil;
        NSString *needSavePhone = nil;
        NSString *needSaveSessionId = nil;
        //3 判断是否为空
        if (curUserName == nil || curUserName.length <= 0) {
            needSaveUserName = @"";//不存在则置为空
        }
        else {
            needSaveUserName = curUserName;
        }
        
        if (curBalance == nil || curBalance.length <= 0) {
            needSaveBalance = @"";//不存在则置为空
        }
        else {
            needSaveBalance = curBalance;
        }
        
        if (curPhone == nil || curPhone.length <= 0) {
            needSavePhone = @"";//不存在则置为空
        }
        else {
            needSavePhone = curPhone;
        }
        
        if (cruSessionId == nil || cruSessionId.length <= 0) {
            needSaveSessionId = @"";//不存在则置为空
        }
        else {
            needSaveSessionId = cruSessionId;
        }
        

        // 1 用户不存在，则add
        NSDictionary *userInfoDic=@{@"userInfoName":userinfo.username,@"userinfoPassword":userinfo.password,@"userId":userinfo.userId,@"userInfoBalance":userinfo.balance,@"userInfoPhone":userinfo.phoneNumber,@"userInfoSessionId":userinfo.sessionId};
        [tempArr addObject:userInfoDic];
        //remove original data
        [userDefault removeObjectForKey:@"usedUserArray"];
        //save new data
        [userDefault setObject:tempArr forKey:@"usedUserArray"];
        [userDefault synchronize];
    
    // 2 用户不存在时，设置当前的用户信息
    //userInfoName userinfoPassword userId userInfoBalance  nsuserdefault userInfoSessionId中存当前用户字段
    NSUserDefaults *cruUserDefault = [NSUserDefaults standardUserDefaults];
    [cruUserDefault setObject:userinfo.username forKey:@"userInfoName"];
    [cruUserDefault setObject:userinfo.balance forKey:@"userInfoBalance"];
    [cruUserDefault setObject:userinfo.userId forKey:@"userId"];
    [cruUserDefault setObject:userinfo.password forKey:@"userinfoPassword"];
    [cruUserDefault setObject:userinfo.phoneNumber forKey:@"userInfoPhone"];
    [cruUserDefault setObject:userinfo.sessionId forKey:@"userInfoSessionId"];
    [cruUserDefault synchronize];
        
    }
    return YES;
}

//logout for 2.0
- (void)logOut {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    /*
    NSString *cruUserName = [userDefault valueForKey:@"userInfoName"];
    NSString *cruUserInfoBalance = [userDefault valueForKey:@"userInfoBalance"];
    NSString *cruUserId = [userDefault valueForKey:@"userId"];
    NSString *cruPassword = [userDefault valueForKey:@"userinfoPassword"];
    NSString *cruPhone = [userDefault valueForKey:@"userInfoPhone"];
     */
    //remove userId
    [userDefault removeObjectForKey:@"userId"];
    //remove userName
    [userDefault removeObjectForKey:@"userInfoName"];
    //remove balance
    [userDefault removeObjectForKey:@"userInfoBalance"];
    //remove mobile
    [userDefault removeObjectForKey:@"userInfoPhone"];
    //remove password
    [userDefault removeObjectForKey:@"userinfoPassword"];
    [userDefault synchronize];
    
}






//get local Users
-(NSMutableArray*)getUsers
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSMutableArray *usersArray=[NSMutableArray arrayWithCapacity:0];
    [usersArray addObjectsFromArray:[userDefault objectForKey:@"usedUserArray"]];
    if (usersArray==NULL) {
        return  NULL;
    }
    return usersArray;
}





//getUserInfo  for 2.0
-(UserInfo*)getUserInfo:(NSString *)userName{
    if (userName == NULL || [userName isEqualToString:@""]==YES) {
        return NULL;
    }
    NSMutableArray *users=[self getUsers];
    if (users.count<=0 || users == NULL){
        return NULL;
    }
    for (NSDictionary *dic in users) {
        if ([dic[@"userInfoName"] isEqualToString:userName]) {
            //返回用户模型
            UserInfo *userinfo=[[UserInfo alloc] init];
            userinfo.username=dic[@"userInfoName"];
            userinfo.password=dic[@"userinfoPassword"];
            userinfo.userId=dic[@"userId"];
            userinfo.balance=dic[@"userInfoBalance"];
            return userinfo;
        }
        else
        {
            return NULL;
        }
    }
    return nil;
    
}



//set userInfo---仿写
-(BOOL)setCurUser:(UserInfo*)userInfo
{
    if (userInfo == NULL || userInfo.username == NULL
        || [userInfo.username isEqualToString:@""]) {
        return NO;
    }
    NSMutableArray *usersArray=[NSMutableArray arrayWithCapacity:0];
    usersArray=[self getUsers];
    if (usersArray==NULL) {
        NSMutableArray*userInfoArrNew=[NSMutableArray array];
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:userInfoArrNew forKey:@"usedUserArray"];
        [userDefault synchronize];
    }
    UserInfo *originalUserInfo=[self getUserInfo:userInfo.username];
    if (originalUserInfo != NULL) {
        // merge
        NSString *userId = (userInfo.userId != NULL
                        && [userInfo.userId isEqualToString:@""]==NO ? userInfo.userId
                        : originalUserInfo.userId);
        userInfo.userId = userId;
        
    }
    [self saveUserInfo:userInfo];
    
    return YES;
}
//set current user
-(void)setCurUser
{
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *paramater=@{@"encrypt_method":@"0",@"encrypt_key_type":@"0",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]};
    
    [manager POST:@"http://zaxue100.com/index.php?c=passportctrl&m=get_user_info" parameters:paramater success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSDictionary *dic=responseObject;
        //解析-得到用户的邮箱
        NSString *email=[self getEmailFromDictionary:dic];

        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        //change current userinfo
        [userDefault setObject:email forKey:@"userInfoEmail"];
        //save into usedUserinfoArray
        NSMutableArray *userInfoArr=[NSMutableArray arrayWithCapacity:0];
        [userInfoArr addObjectsFromArray:[userDefault objectForKey:@"usedUserArray"]];
        [userDefault removeObjectForKey:@"usedUserArray"];
        NSString *currentUserName=[userDefault objectForKey:@"userInfoName"];
        NSString *currentPassword=[userDefault objectForKey:@"userinfoPassword"];
        //先匹配到用户再修改
        for (NSDictionary *userInfoDic in [userDefault objectForKey:@"usedUserArray"])
        {
            index++;
            
            if ([[userInfoDic objectForKey:@"userInfoName"] isEqualToString:currentUserName]) {
                break;
            }
        }
        if (index==userInfoArr.count) {
            NSDictionary *dic=@{@"userInfoName":currentUserName,@"userinfoPassword":currentPassword,@"userInfoEmail":email};
            [userInfoArr addObject:dic];
            //remove old
            [userDefault removeObjectForKey:@"usedUserArray"];
            //save new
            [userDefault setObject:userInfoArr forKey:@"usedUserArray"];
            [userDefault synchronize];
        }
        else {
            [userInfoArr removeObjectAtIndex:index-1];
            //存成字典
            NSDictionary *dic=@{@"userInfoName":currentUserName,@"userinfoPassword":currentPassword,@"userInfoEmail":email};
            //加到字典中
            [userInfoArr addObject:dic];
            //remove old
            [userDefault removeObjectForKey:@"usedUserArray"];
            //save new
            [userDefault setObject:userInfoArr forKey:@"usedUserArray"];
            [userDefault synchronize];
        }
        
//        NSString *emailAgain=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoEmail"];
//        LogDebug(@"emailAgain===%@",emailAgain);
//        
        } failure:^(AFHTTPRequestOperation *opeeration,NSError *error){
        LogError(@"网络请求错误");
    }];
    
}
-(NSString *)getEmailFromDictionary:(NSDictionary *)dic
{
    NSString *dataStr=dic[@"data"];
    //服务器返回的是一个字符串，需要先将这个字符串解密，转成json字符串，再将json字符串转成字典
    NSString *jsonStr=[SecurityUtil AES128Decrypt:dataStr andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
//    LogDebug(@"解密后的字符串是%@",jsonStr);
    
    jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    NSString *stra=[self JSONString:jsonStr];
    SBJsonParser *parser=[[SBJsonParser alloc] init];
    NSDictionary *data=[parser objectWithString:stra];
//    LogDebug(@"错误信息是：%@",data[@"msg"]);
    
    NSString *email=data[@"email"];
    return email;
}


//add user
-(BOOL)addUser:(UserInfo *)userInfo andContext:(NSString *)context
{
    if (userInfo==NULL || userInfo.username==NULL || [userInfo.username isEqualToString:@""]==YES) {
        return NO;
    }
    NSMutableArray *userInfoArr=[NSMutableArray arrayWithCapacity:0];
    [userInfoArr addObjectsFromArray:[self getUsers]];
    if (userInfoArr==NULL) {
        NSMutableArray*userInfoArrNew=[NSMutableArray array];
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:userInfoArrNew forKey:@"usedUserArray"];
        [userDefault synchronize];
    }
    BOOL isSave=[self saveUserInfo:userInfo];
    if (isSave) {
        return YES;
    }
    
    return NO;
}

//remove user
-(BOOL)removeUser:(NSString *)userName andContext:(NSString *)context
{
    if (userName==NULL || [userName isEqualToString:@""]==YES) {
        return NO;
    }
    rindex=0;
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSMutableArray *userInfoArr=[NSMutableArray arrayWithCapacity:0];
    [userInfoArr addObjectsFromArray:[self getUsers]];
    for (NSDictionary *userInfoDic in userInfoArr)
    {
        rindex++;
        
        if ([[userInfoDic objectForKey:@"userInfoName"] isEqualToString:userName]) {
            break;
        }
    }
    if (rindex==userInfoArr.count) {
        return NO;
    }
    else {
        [userInfoArr removeObjectAtIndex:rindex-1];
        [userDefault removeObjectForKey:@"usedUserArray"];
        [userDefault setObject:userInfoArr forKey:@"usedUserArray"];
        [userDefault synchronize];
        return YES;
    }
}
//remove all userinfo
-(BOOL)removeAllUserInfo
{
    NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
    [userdefault removeObjectForKey:@"usedUserArray"];
    return YES;
}

//get  online userInfo
-(void)getUserInfo
{
    dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(t, ^{
    //再次发起网络请求,获取用户的余额信息
    NSString *device_id=[DeviceUtil getVendorId];
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
    NSDictionary *parameter=@{@"encrypt_method":@"0",@"encrypt_key_type":@"0",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":device_id};
    
    [manager POST:@"http://zaxue100.com/index.php?c=passportctrl&m=get_user_info" parameters:parameter success:^(AFHTTPRequestOperation *operation,id responsrObject){
        NSDictionary *dic=responsrObject;
        NSString *dataStr=dic[@"data"];
        NSString *jsonStr=[SecurityUtil AES128Decrypt:dataStr andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
//        NSLog(@"userManager.h解密后的字符串是%@",jsonStr);
        jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        NSString *stra=[self JSONString:jsonStr];
        SBJsonParser *parser=[[SBJsonParser alloc] init];
        NSDictionary *data=[parser objectWithString:stra];
        NSString *surplus_score=data[@"surplus_score"];
        [[NSUserDefaults standardUserDefaults] setObject:surplus_score forKey:@"surplus_score"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *email=data[@"email"];
        //储存用户的邮箱
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:email forKey:@"userInfoEmail"];
        
        [userDefault synchronize];
        [self.userInfo_delegate getUserBalance:surplus_score];
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"登陆失败");
        LogError(@"get userInfo failed because of net connect");
    }];
    });
}

-(NSString *)JSONString:(NSString *)aString {
    NSMutableString *s = [NSMutableString stringWithString:aString];
    //[s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}
//recharge
-(void)getRecharge:(NSString *)cardID
{
    dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(t, ^{
        //将object对象转成json
        SBJsonWriter *jsonWriter=[[SBJsonWriter alloc] init];
        NSError *error;
        //kmlin b
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"user_name",cardID,@"card_id",@"1",@"recharge_type",nil];
        NSString *jsonString=[jsonWriter stringWithObject:dic error:&error];

        NSString *string=[SecurityUtil AES128Encrypt:jsonString andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
        //发起网络请求
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        
        NSDictionary *parameter=@{@"encrypt_method":@"2",@"encrypt_key_type":@"3",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":[DeviceUtil getVendorId],@"data":string};
       
        [manager POST:@"http://zaxue100.com/index.php?c=chargectrl&m=recharge" parameters:parameter success:^(AFHTTPRequestOperation *operation ,id responseobject){
            NSDictionary *dic=responseobject;
            
            NSString *dataStr=dic[@"data"];
            NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
            
            [self.recharge_delegate getRechargeMessage:data[@"msg"]];
        } failure:^(AFHTTPRequestOperation *operation,NSError *error){
            LogError(@"recharge failed because of net connect");
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"由于您的网络问题导致充值失败，请检查您的网络" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"检查网络", nil];
            [alert show];
        }];
    });
}


//实现充值后刷新余额
-(void)getBalance
{
    dispatch_queue_t t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(t, ^{
        //再次发起网络请求,获取用户的余额信息
        NSString *device_id=[DeviceUtil getVendorId];
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
        NSDictionary *parameter=@{@"encrypt_method":@"0",@"encrypt_key_type":@"0",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":device_id};
        
        [manager POST:@"http://zaxue100.com/index.php?c=passportctrl&m=get_user_info" parameters:parameter success:^(AFHTTPRequestOperation *operation,id responsrObject){
            
            NSDictionary *dic=responsrObject;
            NSString *dataStr=dic[@"data"];
            NSString *jsonStr=[SecurityUtil AES128Decrypt:dataStr andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
            jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
            NSString *stra=[self JSONString:jsonStr];
            SBJsonParser *parser=[[SBJsonParser alloc] init];
            NSDictionary *data=[parser objectWithString:stra];
            NSString *surplus_score=data[@"surplus_score"];
            [[NSUserDefaults standardUserDefaults] setObject:surplus_score forKey:@"surplus_score"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.upDateBalance_delegate upDateBalance:surplus_score];
        } failure:^(AFHTTPRequestOperation *operation,NSError *error){
            LogError(@"get userInfo failed because of net connect");
        }];
    });
}


@end
