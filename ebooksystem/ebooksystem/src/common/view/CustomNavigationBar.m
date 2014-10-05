//
//  CustomNavigationBar.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomNavigationBar.h"

@interface CustomNavigationBar ()

@property(nonatomic,strong)UIImageView *backgroundView;
@property(nonatomic,strong)UILabel *titleLable;
@property(nonatomic,strong)UIButton *backButton;

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
    self.backgroundView.backgroundColor=[UIColor blackColor];
    //创建标题
    self.titleLable=[[UILabel alloc] initWithFrame:CGRectMake((self.backgroundView.frame.size.width-60)/2,0, 80, 44)];
    self.titleLable.textColor=[UIColor whiteColor];
    self.titleLable.font=[UIFont systemFontOfSize:16.0f];
    //使用kvo来得到值
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.backgroundView addSubview:self.titleLable];
    
    //返回按钮
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame=CGRectMake(10, 0, 40, 44);
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    self.backButton.titleLabel.font=[UIFont systemFontOfSize:12.0f];
    [self.backButton addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.backButton];
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
