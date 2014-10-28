//
//  CustomRechargeView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomRechargeView.h"
#import "CustomViewCellTableViewCell.h"
#import "UIColor+Hex.h"
#define TABLEVIEW_X 64
#define TABLEVIEW_HEIGHT 142
#define HEIGHT 44
@interface CustomRechargeView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)UIButton *button;
@property(nonatomic,strong)CustomViewCellTableViewCell *cell;

@end


@implementation CustomRechargeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createCustomRechargeView];
    }
    return self;
}
-(void)createCustomRechargeView
{
    UIView *backgroundView=[[UIView alloc] initWithFrame:self.bounds];
     backgroundView.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    backgroundView.userInteractionEnabled=YES;
    backgroundView.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    [self addSubview:backgroundView];
    //创建输入窗口--使用table
    self.table=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TABLEVIEW_HEIGHT) style:UITableViewStyleGrouped];
    self.table.dataSource=self;
    self.table.delegate=self;
    self.table.bounces=NO;
    self.table.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    [self.table setSeparatorColor:[UIColor clearColor]];
    [backgroundView addSubview:self.table];
    //创建button
    self.button=[[UIButton alloc] initWithFrame:CGRectMake(0,self.table.frame.size.height, self.frame.size.width,HEIGHT)];
    self.button.titleLabel.font=[UIFont systemFontOfSize:16.0f];
    self.button.titleLabel.textColor=[UIColor colorWithHexString:@"#ffffff" alpha:1];
    self.button.backgroundColor=[UIColor colorWithHexString:@"#44a0ff" alpha:1];
    [self.button setTitle:@"完成验证" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:self.button];
    
    
}
-(void)btnDown:(UIButton *)btn
{
    NSString *cardID=self.cell.rechargeText.text;
    [self.recharge_delegate getRechargeClick:cardID];
    
}

#pragma mark tableview delegate method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"cellID";
    self.cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (self.cell == nil) {
        self.cell = [[CustomViewCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    self.cell.rechargeText.backgroundColor=[UIColor colorWithHexString:@"4e4c4c" alpha:1];
    return self.cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT;
}
#pragma mark 段头的height和title
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleStr=@"购买《干货系列》书籍的读者，输入封面验证码可获赠红包余额可用于购买我们即将上线的收费内容";
    return titleStr;

}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backgorundView=[[UIView alloc] init];
    backgorundView.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    if (section == 0){
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 53)];
        titleLabel.textColor=[UIColor colorWithHexString:@"#aaaaaa" alpha:1];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font=[UIFont systemFontOfSize:14.0f];
        titleLabel.numberOfLines=0;
        titleLabel.text = @"购买《干货系列》书籍的读者，输入封面验证码可获赠红包余额可用于购买我们即将上线的收费内容";
        [backgorundView addSubview:titleLabel];
    }
    return backgorundView;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *backgorundView=[[UIView alloc] init];
    backgorundView.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    return backgorundView;

}
@end
