//
//  CustomMoreView.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomMoreView.h"
#define FONT_SIZE 15.0f
@interface CustomMoreView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)UILabel *lable;
@property(nonatomic,strong)UILabel *upDateLable;

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
    self.table =[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    [self addSubview:self.table];
    self.table.delegate=self;
    self.table.dataSource=self;
    self.table.bounces=NO;
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
            return 3;
        }
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cancle selected effect
   
    NSInteger section=indexPath.section;
    NSInteger row=indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font=[UIFont systemFontOfSize:14.0f];
        cell.textLabel.textColor=[UIColor lightGrayColor];
    }
    switch (section) {
        case 0:
//            cell.textLabel.text=@"登录";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //在这里创建一个lable，这是加到了table上，而不是在cell定制时添加的。
            //现在想改变这个textlable.text
            self.userNameLable=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, cell.frame.size.height)];
            self.userNameLable.textAlignment=UITextAlignmentLeft;
            self.userNameLable.text=@"登录";
            self.userNameLable.font=[UIFont systemFontOfSize:14.0f];
            self.userNameLable.textColor=[UIColor lightGrayColor];
            [cell addSubview:self.userNameLable];
            [self addObserver:self forKeyPath:@"userName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            
            break;
        case 1:
            if (row==0)
            {
                cell.textLabel.text=@"正版验证";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                if (row==1)
                {
                    [self.lable removeFromSuperview];
                    cell.textLabel.text=@"余额:";
                    cell.textLabel.backgroundColor=[UIColor blueColor];
                    self.lable=[[UILabel alloc] initWithFrame:CGRectMake(50,0, 100,44)];
                    self.lable.textColor=[UIColor blueColor];
                    self.lable.text=@"0";
                    //使用kvo实现改变余额的数值
                    [self addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
                    [cell.textLabel addSubview:self.lable];
                    //取消选中效果
                    cell.selectionStyle=UITableViewCellAccessoryNone;
                }
            }
            break;
        case 2:
            if (row==0)
            {
                cell.textLabel.text=@"意见反馈";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            else
            {
                if (row==1)
                {
                    cell.textLabel.text=@"软件更新";
                    [self.upDateLable removeFromSuperview];
                    self.upDateLable=[[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-100, 0, 100, 44)];
                    self.upDateLable.font=[UIFont systemFontOfSize:13.0f];
                    self.upDateLable.textColor=[UIColor lightGrayColor];
                    [cell addSubview:self.upDateLable];
                    
                }
                else
                {
                    cell.textLabel.text=@"关于";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
        default:
            break;
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
#pragma mark 段头的height和title
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    if (section==1)
    {
        return 60.0;
    }
    else
    {
        if (section==2)
        {
            return 30;
        }
    }
    return 44.0;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleStr=@"购买《干货系列》书籍的读者，在此输入封面验证码，即可获赠价值20元的红包";
    if (section==1)
    {
        return titleStr;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cancel selected effect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.more_delegate getSelectIndexPath:indexPath];
    
    if (indexPath.section==2)
    {
        if (indexPath.row==1)
        {
            self.upDateLable.text=@"正在检查更新...";
        }
    }
}


#pragma mark kvo的观察方法
//监听方法只能写一个
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"balance"]) {
        self.lable.text=[self valueForKeyPath:@"balance"];
    }
    
    if ([keyPath isEqualToString:@"userName"]) {
        self.userNameLable.text=[[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
    }

}

@end
