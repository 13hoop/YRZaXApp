//
//  CustomAboutUsview.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-26.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomAboutUsview.h"
#import "UIColor+Hex.h"
#import "Config.h"
#import "AppUtil.h"
#define SCREEN_HEIGHT 480
#define HEIGHT self.frame.size.height
#define WIDTH self.frame.size.width
#define TITLELABLE_HEIGHT 100
#define TITLELABLE_WIDTH 100
#define LABLE_HEIGHT 40
@interface CustomAboutUsview ()
@property(nonatomic,strong)UIView *upView;
@property(nonatomic,strong)UIView *infoView;
@end

@implementation CustomAboutUsview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
        [self createUpView];
        [self createInfoView];
    }
    return self;
}
-(void)createUpView
{
    self.upView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH,HEIGHT*0.4)];
    self.upView.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    [self addSubview:self.upView];
    //create title image
    NSString *path=[[[Config instance] drawableConfig] getImageFullPath:@"logo.png"];
    UIImage *imageLogo=[UIImage imageNamed:path];
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(122, self.upView.frame.size.height*0.2, 74, 74)];
    imageview.image=imageLogo;
    [self.upView addSubview:imageview];
    //create versionLable
    self.versionLable=[[UILabel alloc] initWithFrame:CGRectMake(0, self.upView.frame.size.height*0.7, self.frame.size.width, LABLE_HEIGHT)];
    NSString *currentVersion = [AppUtil getAppVersionStr];
    self.versionLable.text=currentVersion;
    self.versionLable.textColor=[UIColor lightGrayColor];
    self.versionLable.font=[UIFont systemFontOfSize:14.0f];
    self.versionLable.textAlignment=UITextAlignmentCenter;
    
    
    [self.upView addSubview:self.versionLable];
}
-(void)createInfoView
{
    self.infoView=[[UIView alloc] initWithFrame:CGRectMake(0,self.upView.frame.size.height,WIDTH, LABLE_HEIGHT*5+4)];
    self.infoView.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    [self addSubview:self.infoView];
    NSArray *lableWidth=[[NSArray alloc] initWithObjects:@"70",@"70",@"60",@"100",@"70", nil];
    NSArray *titleArr=[NSArray arrayWithObjects:@"官方网站：",@"新浪微博：",@"微信号：",@"用户交流QQ群：",@"客服邮箱：", nil];
    NSArray *contentArr=[NSArray arrayWithObjects:@"www.zaxue100.com",@"@咋学",@"zaxueapp或直接搜索“咋学”添加",@"95174151",@"bug@diyebook.cn", nil];
    NSArray *imageArray=[NSArray arrayWithObjects:[[[Config instance] drawableConfig] getImageFullPath:@"guanwang.png"],[[[Config instance] drawableConfig] getImageFullPath:@"weibo.png"],[[[Config instance] drawableConfig] getImageFullPath:@"weixin.png"],[[[Config instance] drawableConfig] getImageFullPath:@"yonghuqun.png"],[[[Config instance] drawableConfig] getImageFullPath:@"xinxiang.png"], nil];
    //create itemLable
    for (NSUInteger i=0; i<5; i++) {
        //create itemImage
        UIView *backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, i*(LABLE_HEIGHT+1), self.frame.size.width, LABLE_HEIGHT)];
        backgroundView.backgroundColor=[UIColor colorWithHexString:@"4e4c4c" alpha:1];
        [self.infoView addSubview:backgroundView];
        UIImage *image=[UIImage imageNamed:imageArray[i]];
        UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(12, 9, 27, 27)];
        imageview.image=image;
        [backgroundView addSubview:imageview];
        //
        CGFloat width=[lableWidth[i] floatValue];
        UILabel *itemLable=[[UILabel alloc] initWithFrame:CGRectMake(47, 0,width, LABLE_HEIGHT)];
        itemLable.font=[UIFont systemFontOfSize:13.0f];
        itemLable.text=titleArr[i];
        itemLable.backgroundColor=[UIColor colorWithHexString:@"4e4c4c" alpha:1];
        itemLable.textColor=[UIColor colorWithHexString:@"#bdbdbd" alpha:1];
        [backgroundView addSubview:itemLable];
        //
        UILabel *itemContentLable=[[UILabel alloc] initWithFrame:CGRectMake(47+width, 0, self.infoView.frame.size.width-(20+width), LABLE_HEIGHT)];
        itemContentLable.font=[UIFont systemFontOfSize:13.0f];
        itemContentLable.text=contentArr[i];
        itemContentLable.textColor=[UIColor colorWithHexString:@"#bdbdbd" alpha:1];
        itemContentLable.backgroundColor=[UIColor colorWithHexString:@"4e4c4c" alpha:1];
        [backgroundView addSubview:itemContentLable];
    }
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    
    NSUInteger customHeight=16;
    
    if(height>480) {
        customHeight=36;
    }
    //create bottom
    UILabel *companyLable=[[UILabel alloc] initWithFrame:CGRectMake(54, customHeight+self.infoView.frame.size.height+self.upView.frame.size.height, self.infoView.frame.size.width, 10)];
    companyLable.font=[UIFont systemFontOfSize:11.0f];
    companyLable.textColor=[UIColor colorWithHexString:@"#7d7c7c" alpha:1];
    companyLable.text=@"北京三味书库教育科技有限公司 版权所有";
    [self addSubview:companyLable];
    //create
    
    UILabel *copyRightLable=[[UILabel alloc] initWithFrame:CGRectMake(54, customHeight+self.infoView.frame.size.height+self.upView.frame.size.height+16, self.infoView.frame.size.width,10)];
    copyRightLable.font=[UIFont systemFontOfSize:10.0f];
    copyRightLable.textColor=[UIColor colorWithHexString:@"#7d7c7c" alpha:1];
    copyRightLable.text=@"©2014-2015 Sanwei All Rights Reserved";
    [self addSubview:copyRightLable];
}

@end
