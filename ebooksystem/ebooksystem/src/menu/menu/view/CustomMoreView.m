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


@interface CustomMoreView() <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITableViewCell *cell;

// 新菜单样式
- (UITableViewCell *)newStyleMenuItemAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

// 老菜单样式
- (UITableViewCell *)oldStyleMenuItemAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

@end



@implementation CustomMoreView

@synthesize menuStyle;

#pragma mark - properties

- (MenuStyle)menuStyle {
    return MENU_STYLE_NEW; // 新样式菜单
//    return MENU_STYLE_OLD; // 老样式菜单
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self createTable];
    }
    
    return self;
}

- (void)createTable {
    self.table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [self addSubview:self.table];
    self.table.backgroundColor = [UIColor colorWithHexString:@"393636" alpha:1];
    self.table.delegate = self;
    self.table.dataSource = self;
    //    [self.table setSeparatorInset:UIEdgeInsetsZero];
    self.table.showsHorizontalScrollIndicator = NO;
    self.table.showsVerticalScrollIndicator = NO;
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.table.separatorColor = [UIColor colorWithHexString:@"#302d2d" alpha:1];
    self.table.bounces = YES;
    
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

#pragma mark - table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.menuStyle == MENU_STYLE_NEW ? 2 : 3);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = 0;
    
    if (self.menuStyle == MENU_STYLE_NEW) {
        switch (section) {
            case 0:
                numberOfRows = 1;
                break;
                
            case 1:
//                numberOfRows = 4; // 不带测试按钮
                numberOfRows = 5; // 带测试按钮
                break;
                
            default:
                numberOfRows = 0;
                break;
        }
    }
    else {
        switch (section) {
            case 0:
                numberOfRows = 1;
                break;
                
            case 1:
                numberOfRows = 2;
                break;
                
            case 2:
                numberOfRows = 4;
                break;
                
            default:
                numberOfRows = 0;
                break;
        }
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.menuStyle == MENU_STYLE_NEW) {
        return [self newStyleMenuItemAtIndexPath:indexPath inTableView:tableView];
    }
    
    return [self oldStyleMenuItemAtIndexPath:indexPath inTableView:tableView];
}

// 新菜单样式
- (UITableViewCell *)newStyleMenuItemAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"cellMenuItem";
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cell == nil) {
        self.cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
    // set cell background
    UIView *backgroundView = [[UIView alloc] init];
    [self.cell setBackgroundView:backgroundView];
    [self.cell setBackgroundColor:[UIColor colorWithHexString:@"#413e3e" alpha:1]];
    // change select style and backgroundcolor
    self.cell.selectedBackgroundView = [[UIView alloc] initWithFrame:self.cell.frame];
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
            // 在这里创建一个label，这是加到了table上，而不是在cell定制时添加的。
            // 现在想改变这个textlabel.text
            self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, self.cell.frame.size.height)];
            self.userNameLabel.textAlignment = UITextAlignmentLeft;
            self.userNameLabel.font = [UIFont systemFontOfSize:14.0f];
            self.userNameLabel.textColor = [UIColor lightGrayColor];
            [self.cell addSubview:self.userNameLabel];
            
            self.userNameLabel.text = @"用户信息";
            
            break;
        case 1:
            if (row == 0) {
                self.cell.textLabel.text = @"购买《干货系列》图书";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            else if (row == 1) {
                //                    self.cell.textLabel.text=@"分享应用到";
                //                    self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                //                    self.cell.selectionStyle=UITableViewCellAccessoryNone;
                self.cell.textLabel.text = @"意见反馈";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (row == 2) {
                //                        self.cell.textLabel.text=@"意见反馈";
                //                        self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.cell.textLabel.text = @"软件更新";
                [self.updateLable removeFromSuperview];
                self.updateLable = [[UILabel alloc] initWithFrame:CGRectMake(self.cell.frame.size.width - 170, 0, 150, 44)];
                self.updateLable.font = [UIFont systemFontOfSize:13.0f];
                self.updateLable.textColor = [UIColor lightGrayColor];
                self.updateLable.textAlignment = NSTextAlignmentRight;
                [self.cell addSubview:self.updateLable];
            }
            else if (row == 3) {
                //                            self.cell.textLabel.text=@"软件更新";
                //                            [self.upDateLable removeFromSuperview];
                //                            self.upDateLable=[[UILabel alloc] initWithFrame:CGRectMake(self.cell.frame.size.width-100, 0, 100, 44)];
                //                            self.upDateLable.font=[UIFont systemFontOfSize:13.0f];
                //                            self.upDateLable.textColor=[UIColor lightGrayColor];
                //                            [self.cell addSubview:self.upDateLable];
                
                self.cell.textLabel.text = @"关于咋学";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            else if (row == 4) {
                self.cell.textLabel.text = @"测试";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
            
        default:
            break;
    }
    
    return self.cell;
}

// 老菜单样式
- (UITableViewCell *)oldStyleMenuItemAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"cellMenuItem";
    
    self.cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.cell == nil) {
        self.cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        self.cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
    // set cell background
    UIView *backgroundView = [[UIView alloc] init];
    [self.cell setBackgroundView:backgroundView];
    [self.cell setBackgroundColor:[UIColor colorWithHexString:@"#413e3e" alpha:1]];
    // change select style and backgroundcolor
    self.cell.selectedBackgroundView = [[UIView alloc] initWithFrame:self.cell.frame];
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
            // 在这里创建一个label，这是加到了table上，而不是在cell定制时添加的。
            // 现在想改变这个textlabel.text
            self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, self.cell.frame.size.height)];
            self.userNameLabel.textAlignment = UITextAlignmentLeft;
            self.userNameLabel.font = [UIFont systemFontOfSize:14.0f];
            self.userNameLabel.textColor = [UIColor lightGrayColor];
            [self.cell addSubview:self.userNameLabel];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"]) {
                self.userNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfoName"];
            }
            else {
                self.userNameLabel.text = @"登录体验更多精彩内容";
            }
            break;
        case 1:
            if (row == 0) {
                self.cell.textLabel.text = @"正版验证";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else {
                if (row == 1) {
                    [self.lable removeFromSuperview];
                    self.cell.textLabel.text = @"余额:";
                    self.cell.textLabel.backgroundColor = [UIColor clearColor];
                    self.lable = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 44)];
                    self.lable.textColor = [UIColor colorWithHexString:@"#44a0ff" alpha:1];
                    //                    [self addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
                    [self.cell.textLabel addSubview:self.lable];
                    
                    // 取消选中效果
                    self.cell.selectionStyle = UITableViewCellAccessoryNone;
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"]) {
                        self.lable.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"surplus_score"];
                        
                    }
                    else {
                        self.lable.text = @"0";
                    }
                }
            }
            break;
        case 2:
            if (row == 0) {
                self.cell.textLabel.text = @"购买《干货系列》图书";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            else if (row == 1) {
                //                    self.cell.textLabel.text=@"分享应用到";
                //                    self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                //                    self.cell.selectionStyle=UITableViewCellAccessoryNone;
                self.cell.textLabel.text = @"意见反馈";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (row == 2) {
                //                        self.cell.textLabel.text=@"意见反馈";
                //                        self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.cell.textLabel.text = @"软件更新";
                [self.updateLable removeFromSuperview];
                self.updateLable = [[UILabel alloc] initWithFrame:CGRectMake(self.cell.frame.size.width - 170, 0, 150, 44)];
                self.updateLable.font = [UIFont systemFontOfSize:13.0f];
                self.updateLable.textColor = [UIColor lightGrayColor];
                self.updateLable.textAlignment = NSTextAlignmentRight;
                [self.cell addSubview:self.updateLable];
            }
            else if (row == 3) {
                //                            self.cell.textLabel.text=@"软件更新";
                //                            [self.upDateLable removeFromSuperview];
                //                            self.upDateLable=[[UILabel alloc] initWithFrame:CGRectMake(self.cell.frame.size.width-100, 0, 100, 44)];
                //                            self.upDateLable.font=[UIFont systemFontOfSize:13.0f];
                //                            self.upDateLable.textColor=[UIColor lightGrayColor];
                //                            [self.cell addSubview:self.upDateLable];
                
                self.cell.textLabel.text = @"关于咋学";
                self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            break;
            
        default:
            break;
    }
    
    return self.cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - 段头的height和title
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0.0;
    
    if (self.menuStyle == MENU_STYLE_NEW) {
        switch (section) {
            case 0:
                height = 26.0;
                break;
                
            case 1:
                height = 28.0;
                break;
                
            default:
                break;
        }
    }
    else {
        switch (section) {
            case 0:
                height = 26.0;
                break;
                
            case 1:
                height = 58.0;
                break;
                
            default:
                height = 28.0;
                break;
        }
    }
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.menuStyle != MENU_STYLE_NEW && section == 1) {
        return [Config instance].userConfig.tipForUserCharge;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    //    if (section==2) {
    //        return 20;
    //    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //cancel selected effect
    //    self.cell.backgroundColor=[UIColor colorWithHexString:@"#6d6d6d" alpha:1];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 通过delegate进行处理
    {
        ViewItemId viewItemId = VIEW_ITEM_NONE;
        if (self.menuStyle == MENU_STYLE_NEW) {
            switch (indexPath.section) {
                case 0:
                    viewItemId = VIEW_ITEM_USER_INFO_VIA_WEB;
                    break;
                    
                case 1:
                {
                    switch (indexPath.row) {
                        case 0:
                            viewItemId = VIEW_ITEM_PURCHASE;
                            break;
                            
                        case 1:
                            viewItemId = VIEW_ITEM_FEEDBACK;
                            break;
                            
                        case 2:
                            viewItemId = VIEW_ITEM_CHECK_APP_UPDATE;
                            break;
                            
                        case 3:
                            viewItemId = VIEW_ITEM_ABOUT_APP;
                            break;
                            
                        case 4:
                            viewItemId = VIEW_ITEM_TEST;
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
        else {
            switch (indexPath.section) {
                case 0:
                    viewItemId = VIEW_ITEM_USER_INFO_VIA_NATIVE;
                    break;
                    
                case 1:
                    if (indexPath.row == 0) {
                        viewItemId = VIEW_ITEM_USER_CHARGE;
                    }
                    break;
                    
                case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                            viewItemId = VIEW_ITEM_PURCHASE;
                            break;
                            
                        case 1:
                            viewItemId = VIEW_ITEM_FEEDBACK;
                            break;
                            
                        case 2:
                            viewItemId = VIEW_ITEM_CHECK_APP_UPDATE;
                            break;
                            
                        case 3:
                            viewItemId = VIEW_ITEM_ABOUT_APP;
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
        
        if (self.more_delegate && [self.more_delegate respondsToSelector:@selector(viewItemClicked:)]) {
            [self.more_delegate viewItemClicked:viewItemId];
        }
    }
    
    // 在菜单上显示更新提示
    BOOL shouldShowCheckUpdateTip = NO;
    if ((self.menuStyle == MENU_STYLE_NEW && indexPath.section == 1 && indexPath.row == 2)
        || (self.menuStyle == MENU_STYLE_OLD && indexPath.section == 2 && indexPath.row == 2)) {
        shouldShowCheckUpdateTip = YES;
    }
    
    if (shouldShowCheckUpdateTip) {
        self.updateLable.text = @"正在检查更新...";
    }
}

//set header&& footer backgroundView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor colorWithHexString:@"#393636" alpha:1];
    
    if (self.menuStyle == MENU_STYLE_OLD && section == 1) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 53)];
        titleLabel.textColor=[UIColor colorWithHexString:@"5d5b5b" alpha:1];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font=[UIFont systemFontOfSize:13.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        titleLabel.text = [Config instance].userConfig.tipForUserCharge;
        [myView addSubview:titleLabel];
    }
    
    return myView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *myview = [[UIView alloc] init];
    myview.backgroundColor=[UIColor colorWithHexString:@"#393636" alpha:1];
    return myview;
}


- (void)viewWillDisappear:(BOOL)animated {
    self.cell.backgroundColor=[UIColor colorWithHexString:@"#413e3e" alpha:1];
}

// 去掉粘性效果
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 56;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


@end
