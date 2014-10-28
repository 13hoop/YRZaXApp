//
//  CustomMoreView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomMoreView.h"

#import <QuartzCore/QuartzCore.h>

#import "Config.h"

#import "UIColor+Hex.h"




#define FONT_SIZE 15.0f
@interface CustomMoreView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)UILabel *upDateLable;
@property(nonatomic,strong)UITableViewCell *cell;
@end

@implementation CustomMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self cretaeTable];
        
    }
    return self;
}
-(void)cretaeTable
{
    self.table =[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self addSubview:self.table];
    self.table.backgroundColor=[UIColor colorWithHexString:@"393636" alpha:1];
    self.table.delegate=self;
    self.table.dataSource=self;
    //    [self.table setSeparatorInset:UIEdgeInsetsZero];
    self.table.showsHorizontalScrollIndicator=NO;
    self.table.showsVerticalScrollIndicator=NO;
    self.table.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor=[UIColor colorWithHexString:@"#302d2d" alpha:1];
    self.table.bounces=NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.table.separatorInset = UIEdgeInsetsZero;
    }
    
    // No separator insets
    {
        if ([self.table respondsToSelector:@selector(separatorInset)]) {
            self.table.separatorInset = UIEdgeInsetsZero;
        }
        
        if ([self.table respondsToSelector:@selector(layoutMargins)]) {
            self.table.layoutMargins = UIEdgeInsetsZero;
        }
    }
}
#pragma mark table的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0){
        return 1;
    }
    else
    {
        if (section==1) {
            return 2;
        }
        else{
            return 5;
        }
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cancle selected effect
   
    NSInteger section=indexPath.section;
    NSInteger row=indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cell == nil) {
        self.cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.cell.textLabel.font=[UIFont systemFontOfSize:14.0f];
        self.cell.textLabel.textColor=[UIColor lightGrayColor];
    }
    //set cell background
    UIView *backgroundView=[[UIView alloc] init];
    [self.cell setBackgroundView:backgroundView];
    [self.cell setBackgroundColor:[UIColor colorWithHexString:@"#413e3e" alpha:1]];
    //change select style and backgroundcolor
    self.cell.selectedBackgroundView=[[UIView alloc] initWithFrame:self.cell.frame];
    self.cell.selectedBackgroundView.backgroundColor=[UIColor colorWithHexString:@"#6d6d6d" alpha:1];
    
    // No separator insets
    {
        if ([self.cell respondsToSelector:@selector(separatorInset)]) {
            self.cell.separatorInset = UIEdgeInsetsZero;
        }
        
        if ([self.cell respondsToSelector:@selector(layoutMargins)]) {
            self.cell.layoutMargins = UIEdgeInsetsZero;
        }
    }
    
    switch (section) {
        case 0:

            self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //在这里创建一个lable，这是加到了table上，而不是在cell定制时添加的。
            //现在想改变这个textlable.text
            self.userNameLable=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, self.cell.frame.size.height)];
            self.userNameLable.textAlignment=UITextAlignmentLeft;
            self.userNameLable.font=[UIFont systemFontOfSize:14.0f];
            self.userNameLable.textColor=[UIColor lightGrayColor];
            [self.cell addSubview:self.userNameLable];

            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"])
            {
                self.userNameLable.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
            }
            else
            {
                self.userNameLable.text=@"登录体验更多精彩内容";
            }
            break;
        case 1:
            if (row==0)
            {
                self.cell.textLabel.text=@"正版验证";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                if (row==1)
                {
                    [self.lable removeFromSuperview];
                    self.cell.textLabel.text=@"余额:";
                    self.cell.textLabel.backgroundColor=[UIColor clearColor];
                    self.lable=[[UILabel alloc] initWithFrame:CGRectMake(50,0, 100,44)];
                    self.lable.textColor=[UIColor colorWithHexString:@"#44a0ff" alpha:1];
//                    [self addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
                    [self.cell.textLabel addSubview:self.lable];
                    //取消选中效果
                    self.cell.selectionStyle=UITableViewCellAccessoryNone;
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"])
                    {
                        self.lable.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"];
                        
                    }
                    else
                    {
                        self.lable.text=@"0";
                    }
                }
            }
            break;
        case 2:
            if (row==0)
            {
                self.cell.textLabel.text=@"购买《干货系列》图书";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            else
            {
                if (row==1)
                {
                    self.cell.textLabel.text=@"分享应用到";
                    self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    self.cell.selectionStyle=UITableViewCellAccessoryNone;

                    
                    
                }
                else
                {
                    if (row==2) {
                        self.cell.textLabel.text=@"意见反馈";
                        self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    else
                    {
                        if (row==3) {
                            self.cell.textLabel.text=@"软件更新";
                            [self.upDateLable removeFromSuperview];
                            self.upDateLable=[[UILabel alloc] initWithFrame:CGRectMake(self.cell.frame.size.width-100, 0, 100, 44)];
                            self.upDateLable.font=[UIFont systemFontOfSize:13.0f];
                            self.upDateLable.textColor=[UIColor lightGrayColor];
                            [self.cell addSubview:self.upDateLable];
                        }
                        else
                        {
                            if (row==4) {
                                self.cell.textLabel.text=@"关于咋学";
                                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                            }
                          
                           
                        }
                    }
                }
                
            }
        default:
            break;
    }
    return self.cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
#pragma mark 段头的height和title
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    if (section==0)
    {
        return 26.0;
        
    }
    else
    {
        if (section==1)
        {
            return 58.0;
        }
    }
    return 28.0;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleStr = [Config instance].userConfig.tipForUserCharge;
    if (section == 1) {
        return titleStr;
    }
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section==0)
    {
        return 10;
    }
    if (section==2) {
        return 20;
    }
    return 1;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cancel selected effect
//    self.cell.backgroundColor=[UIColor colorWithHexString:@"#6d6d6d" alpha:1];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.more_delegate getSelectIndexPath:indexPath];
    
    if (indexPath.section==2)
    {
        if (indexPath.row==3)
        {
            self.upDateLable.text=@"正在检查更新...";
        }
    }
}
//set header&& footer backgroundView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor colorWithHexString:@"#393636" alpha:1];
    
    
    if (section == 1){
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 53)];
        titleLabel.textColor=[UIColor colorWithHexString:@"5d5b5b" alpha:1];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font=[UIFont systemFontOfSize:14.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines=0;
        titleLabel.text = [Config instance].userConfig.tipForUserCharge;
        [myView addSubview:titleLabel];
    }
    
    
    return myView;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *myview=[[UIView alloc] init];
    myview.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    return myview;
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    self.cell.backgroundColor=[UIColor colorWithHexString:@"#413e3e" alpha:1];
    
}
//#pragma mark kvo delegate method
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if([keyPath isEqualToString:@"balance"])
//    {
//        self.lable.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"];
//    }
//}


@end
