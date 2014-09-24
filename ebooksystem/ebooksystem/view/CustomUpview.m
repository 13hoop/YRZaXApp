//
//  CustomUpview.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomUpview.h"

@implementation CustomUpview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createUpview];
    }
    return self;
}

-(void)createUpview
{
    UIView *backgoundView=[[UIView alloc] initWithFrame:self.bounds];
    backgoundView.userInteractionEnabled=YES;
    
    //后期改成图片
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    //    view.backgroundColor=[UIColor colorWithRed:55.0f green:55.0f blue:55.0f alpha:1.0];
    view.backgroundColor=[UIColor blackColor];
    //
    UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(140, 0, 40, 44)];
    titleLable.text=@"咋学";
    titleLable.textColor=[UIColor whiteColor];
    [view addSubview:titleLable];
    [backgoundView addSubview:view];
    //添加更多按钮
    UIButton *moreBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame=CGRectMake(self.frame.size.width-10-40,5,40, 34);
    moreBtn.titleLabel.font=[UIFont systemFontOfSize:12.0f];
    [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:moreBtn];
    //添加下面的Imageview
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, self.frame.size.height-44)];
    imageview.image=[UIImage imageNamed:@"1.jpeg"];
    [backgoundView addSubview:imageview];
    [self addSubview:backgoundView];
    
}
-(void)btnDown:(UIButton *)btn
{
    [self.more_delegate getClick:btn];
}

@end
