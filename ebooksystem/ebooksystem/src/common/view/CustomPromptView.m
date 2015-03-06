//
//  CustomPromptView.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/3/6.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "CustomPromptView.h"
#import "Config.h"

#define LABLEHIGHT 40
#define LABLEWIDTH 266
#define IMAGEWIDTH 138
#define IMAGEHIGHT 128
@implementation CustomPromptView


- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self creaImageView];
    
}

//创建提示imageview
- (void)creaImageView {
    //创建背景视图
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.frame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
    //创建提示图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - IMAGEWIDTH)/2, (self.frame.size.width - IMAGEHIGHT - LABLEHIGHT)/2, IMAGEWIDTH, IMAGEHIGHT)];
    UIImage *image = [UIImage imageNamed:[[[Config instance] drawableConfig] getImageFullPath:@"network_status_bg_icon"]];
    imageView.image = image;
    [backgroundView addSubview:imageView];
    //创建提示lable
    UILabel *promptLable = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-LABLEWIDTH)/2, self.frame.size.height - ((self.frame.size.width - IMAGEHIGHT - LABLEHIGHT)/2 +IMAGEHIGHT), LABLEWIDTH, LABLEHIGHT)];
    promptLable.text = @"网络不给力，请检查网络连接后重试";
    promptLable.font = [UIFont systemFontOfSize:14.0f];
    promptLable.textAlignment = NSTextAlignmentCenter;
    promptLable.textColor = [UIColor lightGrayColor];
    [backgroundView addSubview:promptLable];
    
}


@end
