//
//  MatchViewController.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-11-5.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchViewController : UIViewController
@property(nonatomic,strong)NSString *webUrl;
-(void)showWebUrl:(NSString *)url;
//js调用接口
-(void)share:(NSDictionary *)shareDic;
@end
