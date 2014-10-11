//
//  CustomRechargeView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-8.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomRechargeViewDelegate <NSObject>

-(void)getRechargeClick:(NSString *)cardID;

@end


@interface CustomRechargeView : UIView

@property(nonatomic,weak)id <CustomRechargeViewDelegate>recharge_delegate;

@end
