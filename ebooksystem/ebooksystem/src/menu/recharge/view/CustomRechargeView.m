//
//  CustomRechargeView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomRechargeView.h"
#import "CustomViewCellTableViewCell.h"
#define TABLEVIEW_X 64
#define TABLEVIEW_HEIGHT 140
#define HEIGHT 40
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
    self.button=[[UIButton alloc] initWithFrame:CGRectMake(0,TABLEVIEW_HEIGHT, self.frame.size.width,HEIGHT)];
    self.button.backgroundColor=[UIColor blueColor];
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

    return self.cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT;
}
#pragma mark 段头的height和title
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleStr=@"购买《干货系列》书籍的读者，在此输入封面验证码，即可获赠价值20元的红包";
    return titleStr;

}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

@end
