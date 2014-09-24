//
//  CustomDownview.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomDownview.h"

@implementation CustomDownview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createView];
    }
    return self;
}
-(void)createView
{
    UIScrollView *scrollerView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320,self.frame.size.height)];
    //修改成图片
    scrollerView.backgroundColor=[UIColor lightGrayColor];
    scrollerView.contentSize=CGSizeMake(self.frame.size.width, self.frame.size.height+10);
    scrollerView.userInteractionEnabled=YES;
    //考研英语
    NSArray *titleArr=[[NSArray alloc] initWithObjects:@"考研英语",@"考研政治", nil];
    
    for (NSUInteger i=0; i<2; i++)
    {
        UIImageView *englishBackground=[[UIImageView alloc] initWithFrame:CGRectMake(0, 10+i*((self.frame.size.height-40)/2+10), self.frame.size.width, (self.frame.size.height-40)/2)];
        
        englishBackground.backgroundColor=[UIColor whiteColor];
        englishBackground.userInteractionEnabled=YES;
        //图书图标
        UIImageView *englishImage=[[UIImageView alloc] initWithFrame:CGRectMake(10,15,70, (self.frame.size.height-40)/2-30)];
        englishImage.backgroundColor=[UIColor blueColor];
        [englishBackground addSubview:englishImage];
        //标题
        UILabel *titleLable=[[UILabel alloc] initWithFrame:CGRectMake(90,15,self.frame.size.width-90-30, 20)];
        titleLable.text=titleArr[i];
        [englishBackground addSubview:titleLable];
        //简介--固定or网络请求值
        UILabel *infoLable=[[UILabel alloc] initWithFrame:CGRectMake(90, 35, self.frame.size.width-90-30, (self.frame.size.height-40)/2-30-20)];
        infoLable.numberOfLines=0;
        infoLable.font=[UIFont systemFontOfSize:12.0f];
        infoLable.text=@"简介";
        [englishBackground addSubview:infoLable];
        [scrollerView addSubview:englishBackground];
    }
    [self addSubview:scrollerView];
}
@end
