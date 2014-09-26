//
//  CustomDownview.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomDownview.h"
#import "CustomTableViewCell.h"
@interface CustomDownview()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *dataSourceArr;
@end

@implementation CustomDownview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dataSourceArr=[NSMutableArray array];
        //数据源数组中的每个元素都是一个字典
        NSString *englishContentStr=@"关联词汇分组式记忆，历年真题碎片化讲解。考什么学什么，帮你减轻考研英语压力。";
        NSString *politicsContentstr=@"重要考点习题，疑难知识点精讲。第一款权威考研政治APP。形势与政策、20天20题即将上线，敬请期待";
        NSDictionary *englishDic=[NSDictionary dictionaryWithObjectsAndKeys:@"haha",@"bookImage",@"考研英语",@"title",englishContentStr,@"content", nil];
        NSDictionary *politicsDic=[NSDictionary dictionaryWithObjectsAndKeys:@"haha",@"bookImage",@"考研政治",@"title",politicsContentstr,@"content", nil];
        [self.dataSourceArr addObject:englishDic];
        [self.dataSourceArr addObject:politicsDic];
        [self createTable];
    }
    return self;
}

-(void)createTable
{
    self.table =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.table.delegate=self;
    self.table.dataSource=self;
    //去掉cell上的分割线
    self.table.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.table.bounces=NO;
    
    [self addSubview:self.table];
    
}
#pragma mark tableview delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return (self.frame.size.height-40)/2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId=@"eBookSystem";
    CustomTableViewCell *cell=(CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell==nil)
    {
        cell=[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId withHeight:(self.frame.size.height-40)/2];
//        cell=[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    
    
    NSDictionary *dic=[self.dataSourceArr objectAtIndex:indexPath.row];
//    cell.bookImage=[UIImage imageNamed:@"<#string#>"];
    
    cell.titleLable.text=dic[@"title"];
    cell.contentLable.text=dic[@"content"];
    NSLog(@"table self.frame.size.height==%f",self.frame.size.height);
    return cell;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"宣中的是第几行：%d",indexPath.row);
    
}
@end
