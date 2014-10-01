//
//  CustomAboutUsview.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-26.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomAboutUsview.h"
#define SCREEN_HEIGHT 480
#define HEIGHT self.frame.size.height
#define WIDTH self.frame.size.width
#define TITLELABLE_HEIGHT 100
#define TITLELABLE_WIDTH 100
#define LABLE_HEIGHT 20
@interface CustomAboutUsview ()

@end

@implementation CustomAboutUsview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createUpView];
        [self createInfoView];
    }
    return self;
}
-(void)createUpView
{
    UIView *upView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH,HEIGHT*0.6)];
    upView.backgroundColor=[UIColor whiteColor];
    [self addSubview:upView];
    //create titleLable
    UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(0, (upView.frame.size.height-TITLELABLE_HEIGHT)/2,self.frame.size.width, TITLELABLE_HEIGHT)];
    titleLable.font=[UIFont systemFontOfSize:40.0f];
    titleLable.textAlignment=UITextAlignmentCenter;
    titleLable.text=@"咋学";
    [upView addSubview:titleLable];
    //create versionLable
    self.versionLable=[[UILabel alloc] initWithFrame:CGRectMake(0, (upView.frame.size.height-TITLELABLE_HEIGHT)/2+TITLELABLE_HEIGHT, self.frame.size.width, LABLE_HEIGHT)];
    self.versionLable.text=@"1.0.7.0-10";
    self.versionLable.textColor=[UIColor lightGrayColor];
    self.versionLable.font=[UIFont systemFontOfSize:14.0f];
    self.versionLable.textAlignment=UITextAlignmentCenter;
    [self addObserver:self forKeyPath:@"versionStr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [upView addSubview:self.versionLable];
}
-(void)createInfoView
{
    UIView *infoView=[[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT*0.6, WIDTH, HEIGHT*0.4)];
    infoView.backgroundColor=[UIColor whiteColor];
    [self addSubview:infoView];
    NSArray *lableWidth=[[NSArray alloc] initWithObjects:@"70",@"70",@"60",@"100",@"70", nil];
    NSArray *titleArr=[NSArray arrayWithObjects:@"官方网站：",@"新浪微博：",@"微信号：",@"用户交流QQ群：",@"客服邮箱：", nil];
    NSArray *contentArr=[NSArray arrayWithObjects:@"www.zaxue100.com",@"@咋学",@"zaxueapp或直接搜索“咋学”添加",@"162140049",@"bug@diyebook.cn", nil];
    //create itemLable
    for (NSUInteger i=0; i<5; i++) {
        CGFloat width=[lableWidth[i] floatValue];
        UILabel *itemLable=[[UILabel alloc] initWithFrame:CGRectMake(20, i*LABLE_HEIGHT,width, LABLE_HEIGHT)];
        itemLable.font=[UIFont systemFontOfSize:13.0f];
        itemLable.text=titleArr[i];
        itemLable.textColor=[UIColor grayColor];
        [infoView addSubview:itemLable];
        UILabel *itemContentLable=[[UILabel alloc] initWithFrame:CGRectMake(20+width, i*LABLE_HEIGHT, infoView.frame.size.width-(20+width), LABLE_HEIGHT)];
        itemContentLable.font=[UIFont systemFontOfSize:13.0f];
        itemContentLable.text=contentArr[i];
        itemContentLable.textColor=[UIColor grayColor];
        [infoView addSubview:itemContentLable];
    }
    //create bottom
    UILabel *companyLable=[[UILabel alloc] initWithFrame:CGRectMake(0, infoView.frame.size.height-50, infoView.frame.size.width, LABLE_HEIGHT)];
    companyLable.font=[UIFont systemFontOfSize:11.0f];
    companyLable.textColor=[UIColor lightGrayColor];
    companyLable.text=@"北京三味书库教育科技有限公司 版权所有";
    companyLable.textAlignment=UITextAlignmentCenter;
    [infoView addSubview:companyLable];
    //create
    UILabel *copyRightLable=[[UILabel alloc] initWithFrame:CGRectMake(0, infoView.frame.size.height-30, infoView.frame.size.width, LABLE_HEIGHT)];
    copyRightLable.textAlignment=UITextAlignmentCenter;
    copyRightLable.font=[UIFont systemFontOfSize:11.0f];
    copyRightLable.textColor=[UIColor lightGrayColor];
    [infoView addSubview:copyRightLable];
    copyRightLable.text=@"2014-2015 Sanwei ALL Rights Reserved";
}
#pragma mark observe method
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"versionStr"])
    {
        self.versionLable.text=[self valueForKeyPath:@"versionStr"];
        
    }
}
@end
