//
//  TestViewController.m
//  ebooksystem
//
//  Created by zhenghao on 11/27/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "TestViewController.h"

#import "Config.h"

#import "CommonWebViewController.h"
#import "CustomNavigationBar.h"

#import "UIColor+Hex.h"


@interface TestViewController () <UITableViewDataSource, UITableViewDelegate, CustomNavigationBarDelegate>

@property(nonatomic,strong) CustomNavigationBar *navBar;


- (void)showAlipayViaWeb;

@end



@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#242021" alpha:1];
    [self addNavigationBar];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
//    self.tableView.backgroundColor = [UIColor grayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
}

-(void)addNavigationBar {
    self.navBar = [[CustomNavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    self.navBar.title = @"测试";
    self.navBar.customNav_delegate = self;
    [self.view addSubview:self.navBar];
}

#pragma mark - table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows = 1;
            break;
            
        default:
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"cellTest";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    [cell setBackgroundColor:[UIColor colorWithHexString:@"#413e3e" alpha:1]];
    
//    // set cell background
//    UIView *backgroundView = [[UIView alloc] init];
//    [cell setBackgroundView:backgroundView];
//    [cell setBackgroundColor:[UIColor colorWithHexString:@"#413e3e" alpha:1]];
//    // change select style and backgroundcolor
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#6d6d6d" alpha:1];
//    
    // No separator insets
    {
        if ([cell respondsToSelector:@selector(separatorInset)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        if ([cell respondsToSelector:@selector(layoutMargins)]) {
            cell.layoutMargins = UIEdgeInsetsZero;
        }
    }
    
    switch (section) {
        case 0:
            if (row == 0) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"网页支付";
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0.0;
    
    switch (section) {
        case 0:
            height = 26.0;
            break;
            
        default:
            height = 28.0;
            break;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0.0;
    
    switch (section) {
        case 0:
            height = 1.0;
            break;
            
        default:
            height = 1.0;
            break;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"支付宝";
            break;
            
        default:
            break;
    }
    
    return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 28)];
    titleLabel.textColor = [UIColor colorWithHexString:@"ffffff" alpha:1];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:13.0f];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.numberOfLines = 0;
    
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"支付宝";
            break;
            
        default:
            break;
    }
    titleLabel.text = title;
    
    [myView addSubview:titleLabel];

    return myView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    [self showAlipayViaWeb];
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

#pragma mark - CustomNavigationBar delegate methods
- (void)getClick:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlipayViaWeb {
    CommonWebViewController *webViewController = [[CommonWebViewController alloc] init];
    webViewController.url = [Config instance].paymentConfig.urlForAliPayViaWeb;
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
