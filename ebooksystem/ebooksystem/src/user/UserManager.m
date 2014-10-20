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
    userInfo.email = @"";
    userInfo.balance = @"";
    
    return userInfo;
}

// get cur user
- (UserInfo *)getCurUser {
    UserInfo *userInfo = [[UserInfo alloc] init];
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    userInfo.username=[userDefault objectForKey:@"userInfoName"];
    userInfo.password=[userDefault objectForKey:@"userinfoPassword"];
    userInfo.email=[userDefault objectForKey:@"userInfoEmail"];
    userInfo.balance=[userDefault objectForKey:@"userInfoBalance"];
    return userInfo;
}
//save userInfo
-(BOOL)saveUserInfo:(UserInfo *)userinfo
{
    index=0;
    if (userinfo==NULL)
    {
        return NO;
    }
    //先遍历数组，判断是否有重合的数据
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSMutableArray *tempArr=[NSMutableArray arrayWithCapacity:0];
    [tempArr addObjectsFromArray:[userDefault objectForKey:@"usedUserArray"]];
    //判断用户是否已经存在，若存在获取他在数组中的下标
    for (NSDictionary *userInfoDic in [userDefault objectForKey:@"usedUserArray"])
    {
        index++;
        
//        NSLog(@"index====%d",index);
        NSLog(@"tempArr.count====%d",tempArr.count);

        if ([[userInfoDic objectForKey:@"userInfoName"] isEqualToString:userinfo.username])
        {
            
            break;
            
        }
    }
    if (index==tempArr.count) {
        NSDictionary *userInfoDic=@{@"userInfoName":userinfo.username,@"userinfoPassword":userinfo.password,@"userInfoEmail":userinfo.email,@"userInfoBalance":userinfo.balance};
        [tempArr addObject:userInfoDic];
        //remove original data
        [userDefault removeObjectForKey:@"usedUserArray"];
        //save new data
        [userDefault setObject:tempArr forKey:@"usedUserArray"];
        [userDefault synchronize];
        NSLog(@"这是新用户需要存入");
    }
    else
    {
        //首先移除数组中的原始的用户信息
        [tempArr removeObjectAtIndex:index-1];
        //将最新信息存成字典
        NSDictionary *userInfoDic=@{@"userInfoName":userinfo.username,@"userinfoPassword":userinfo.password,@"userInfoEmail":userinfo.email,@"userInfoBalance":userinfo.balance};
        //加到字典中
        [tempArr addObject:userInfoDic];
        //移除本地的老数据
        [userDefault removeObjectForKey:@"usedUserArray"];
        //save新的数据
        [userDefault setObject:tempArr forKey:@"usedUserArray"];
        [userDefault synchronize];
        NSLog(@"用户已经存在，存入最新的信息");
    }
    //test save  is success
    NSMutableArray *testArr=[userDefault objectForKey:@"usedUserArray"];
    for (NSDictionary *tempDic in testArr)
    {
        if ([[tempDic objectForKey:@"userInfoName"] isEqualToString:userinfo.username]) {
            return YES;
        }
    }
    return NO;
    
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
//getUserInfo
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
            userinfo.email=dic[@"userInfoEmail"];
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
        NSString *email = (userInfo.email != NULL
                        && [userInfo.email isEqualToString:@""]==NO ? userInfo.email
                        : originalUserInfo.email);
        userInfo.email = email;
        
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
    
    [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=get_user_info" parameters:paramater success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSDictionary *dic=responseObject;
        //解析-得到用户的邮箱
        NSString *email=[self getEmailFromDictionary:dic];
        NSLog(@"dic===========dic===%@",dic);
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
            NSLog(@"index====%d",index);
            
            if ([[userInfoDic objectForKey:@"userInfoName"] isEqualToString:currentUserName])
            {
                
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
            NSLog(@"这是新用户的email,需要存入");
        }
        else
        {
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
            NSLog(@"用户已经存在，存入修改后的信息");
        }

       
        
        NSString *emailAgain=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoEmail"];
        NSLog(@"emailAgain===%@",emailAgain);
        
        } failure:^(AFHTTPRequestOperation *opeeration,NSError *error){
        NSLog(@"网络请求错误");
    }];
    
}
-(NSString *)getEmailFromDictionary:(NSDictionary *)dic
{
    NSString *dataStr=dic[@"data"];
    //服务器返回的是一个字符串，需要先将这个字符串解密，转成json字符串，再将json字符串转成字典
    NSString *jsonStr=[SecurityUtil AES128Decrypt:dataStr andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
    NSLog(@"解密后的字符串是%@",jsonStr);
    jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    NSString *stra=[self JSONString:jsonStr];
    SBJsonParser *parser=[[SBJsonParser alloc] init];
    NSDictionary *data=[parser objectWithString:stra];
    NSLog(@"错误信息是：%@",data[@"msg"]);
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
        NSLog(@"index====%d",rindex);
        
        if ([[userInfoDic objectForKey:@"userInfoName"] isEqualToString:userName])
        {
            
            break;
            
        }
    }
    if (rindex==userInfoArr.count) {
        return NO;
    }
    else
    {
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
    
    [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=passportctrl&m=get_user_info" parameters:parameter success:^(AFHTTPRequestOperation *operation,id responsrObject){
        
        NSDictionary *dic=responsrObject;
        NSString *dataStr=dic[@"data"];
        NSString *jsonStr=[SecurityUtil AES128Decrypt:dataStr andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
        NSLog(@"解密后的字符串是%@",jsonStr);
        jsonStr=[jsonStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        NSString *stra=[self JSONString:jsonStr];
        SBJsonParser *parser=[[SBJsonParser alloc] init];
        NSDictionary *data=[parser objectWithString:stra];
        NSString *surplus_score=data[@"surplus_score"];
        NSString *email=data[@"email"];
        //储存用户的邮箱
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:email forKey:@"userInfoEmail"];
        NSLog(@"email=====%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoEmail"]);
        [userDefault synchronize];
        [self.userInfo_delegate getUserBalance:surplus_score];
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"登陆失败");
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
        NSLog(@"cardID===%@",cardID);
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"user_name",cardID,@"card_id",@"1",@"recharge_type",nil];
        NSString *jsonString=[jsonWriter stringWithObject:dic error:&error];
        NSLog(@"jsonString==%@",jsonString);
        NSString *string=[SecurityUtil AES128Encrypt:jsonString andwithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"userinfoPassword"]];
        
        NSLog(@"加密后的数据是：%@",string);
        //发起网络请求
        AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"text/html"];
  
        
        NSDictionary *parameter=@{@"encrypt_method":@"2",@"encrypt_key_type":@"3",@"user_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"],@"device_id":[DeviceUtil getVendorId],@"data":string};
       
        
        [manager POST:@"http://s-115744.gotocdn.com:8296/index.php?c=chargectrl&m=recharge" parameters:parameter success:^(AFHTTPRequestOperation *operation ,id responseobject){
            NSDictionary *dic=responseobject;
            
            NSString *dataStr=dic[@"data"];
            NSData *dataData=[dataStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *data=[NSJSONSerialization JSONObjectWithData:dataData options:0 error:nil];
            NSLog(@"message===%@",data[@"msg"]);
            
            //
            [self.recharge_delegate getRechargeMessage:data[@"msg"]];
            
        } failure:^(AFHTTPRequestOperation *operation,NSError *error){
            NSLog(@"请求失败");
        }];
        

        
    });

}



@end
