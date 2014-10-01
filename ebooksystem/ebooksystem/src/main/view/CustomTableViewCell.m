//
//  CustomTableViewCell.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-25.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomTableViewCell.h"
#define IMAGE_HEIGHT self.height-20-20
#define IMAGE_WIDTH (self.height-20-20)*0.7
#define CELL_HEIGHT self.height
@interface CustomTableViewCell()



@end

@implementation CustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor colorWithRed:226/250.0 green:226/250.0 blue:226/250.0 alpha:1.0];
        [self createCustomCell];
    }
    return self;
}
//解决self同在table返回的高度不一致的问题
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHeight:(float)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor colorWithRed:226/250.0 green:226/250.0 blue:226/250.0 alpha:1.0];
        self.height=height;
        [self createCustomCell];
    }
    return self;
}
-(void)createCustomCell
{
    //自定义cell时cell的高度怎么是固定的
    self.backgroundview=[[UIView alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.height-20)];
    self.backgroundview.backgroundColor=[UIColor whiteColor];
    self.backgroundview.userInteractionEnabled=YES;
    [self addSubview:self.backgroundview];
    //创建图书的图标
    [self createBookImage];
    //创建标题
    [self createTitleLable];
    //创建内容标签
    [self createContentLable];
    
    
}
-(void)createBookImage
{
    self.bookImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, 15,IMAGE_WIDTH,IMAGE_HEIGHT)];
    self.bookImage.backgroundColor=[UIColor blueColor];
    [self.backgroundview addSubview:self.bookImage];
    
}
-(void)createTitleLable
{
    self.titleLable=[[UILabel alloc] initWithFrame:CGRectMake(20+IMAGE_WIDTH, 15, self.frame.size.width-(20+IMAGE_WIDTH), 20)];
    [self.backgroundview addSubview:self.titleLable];
    

    
}
-(void)createContentLable
{
    self.contentLable=[[UILabel alloc] initWithFrame:CGRectMake(20+IMAGE_WIDTH,35, self.frame.size.width-(20+IMAGE_WIDTH)-20,IMAGE_HEIGHT-20)];
    self.contentLable.textColor=[UIColor lightGrayColor];
    self.contentLable.font=[UIFont systemFontOfSize:12.0f];
    self.contentLable.numberOfLines=0;
    [self.backgroundview addSubview:self.contentLable];
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
