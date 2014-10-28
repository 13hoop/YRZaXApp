//
//  CustomViewCellTableViewCell.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomViewCellTableViewCell.h"
#import "UIColor+Hex.h"
@interface CustomViewCellTableViewCell()<UITextFieldDelegate>




@end

@implementation CustomViewCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createCustomCell];
    }
    return self;
}
#pragma mark 自定义cell
-(void)createCustomCell
{
    [self removeFromSuperview];
    self.rechargeText=[[CustomTextField alloc] initWithFrame:self.bounds];
    //开启一键清除功能

    self.rechargeText.clearButtonMode=UITextFieldViewModeAlways;
    self.rechargeText.rightViewMode=UITextFieldViewModeAlways;
    self.rechargeText.backgroundColor=[UIColor colorWithHexString:@"#4e4c4c" alpha:1];
    //屏蔽首字母大写
    self.rechargeText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.rechargeText.delegate=self;
    //
    self.rechargeText.borderStyle = UITextBorderStyleNone;
    self.rechargeText.backgroundColor=[UIColor whiteColor];
    self.rechargeText.font=[UIFont systemFontOfSize:14.0f];
    self.rechargeText.placeholder=@"验证码";
    [self addSubview:self.rechargeText];
}
#pragma mark uitextfield delegate method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor=[UIColor whiteColor];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.textColor=[UIColor whiteColor];
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
