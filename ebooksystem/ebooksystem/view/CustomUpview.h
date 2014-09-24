//
//  CustomUpview.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomUpviewDelegate <NSObject>

-(void)getClick:(UIButton *)btn;

@end


@interface CustomUpview : UIView
@property(nonatomic,weak)id <CustomUpviewDelegate> more_delegate;
@end
