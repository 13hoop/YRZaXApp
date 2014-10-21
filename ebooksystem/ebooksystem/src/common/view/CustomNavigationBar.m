//
//  CustomNavigationBar.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomNavigationBar.h"
#import "UIColor+Hex.h"
#import "Config.h"
@interface CustomNavigationBar ()

@property(nonatomic,strong)UIImageView *backgroundView;
@property(nonatomic,strong)UILabel *titleLable;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UIImageView *imageReturn;

@property(nonatomic,strong)UIButton *largeButton;
@end


@implementation CustomNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createNavigationBar];
    }
    return self;
}
-(void)createNavigationBar
{
    self.backgroundView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    self.backgroundView.userInteractionEnabled=YES;
    //需要修改为图片
   
    self.backgroundView.backgroundColor=[UIColor colorWithHexString:@"#2d2727" alpha:1];
    //创建标题
    self.titleLable=[[UILabel alloc] initWithFrame:CGRectMake((self.backgroundView.frame.size.width-80)/2,14, 80, 16)];
    self.titleLable.textAlignment=UITextAlignmentCenter;
    self.titleLable.textColor=[UIColor colorWithHexString:@"#d0cfcf" alpha:1];
    self.titleLable.font=[UIFont systemFontOfSize:16.0f];
    //使用kvo来得到值
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.backgroundView addSubview:self.titleLable];
    
    //返回图标
    self.imageReturn=[[UIImageView alloc] initWithFrame:CGRectMake(13, 13, 10, 15)];
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
//    UIImage *appleImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
//    UIImage *image=[UIImage imageNamed:@"返回切图.png"];
//    UIImage *image=[[[Config instance] drawableConfig] getImageFullPath:@"index_english_cover.png"];
    NSString *path=[[[Config instance] drawableConfig] getImageFullPath:@"back.png"];
    UIImage *image=[UIImage imageNamed:path];
    self.imageReturn.image=image;
    [self.backgroundView addSubview:self.imageReturn];
    //返回按钮
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame=CGRectMake(26, 16, 40, 12);
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    self.backButton.titleLabel.font=[UIFont systemFontOfSize:12.0f];
    self.backButton.titleLabel.textColor=[UIColor colorWithHexString:@"#d0cfcf" alpha:1];
//    [self.backButton addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.backButton];
    //创建button
    self.largeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.largeButton.frame=CGRectMake(0, 0, 60, 44);
    [self.largeButton addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.backgroundView addSubview:self.largeButton];
    [self addSubview:self.backgroundView];
    
}
-(void)btnDown:(UIButton *)btn
{
    [self.customNav_delegate getClick:btn];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"])
    {
        self.titleLable.text=[self valueForKeyPath:@"title"];
        
    }
}

@end
