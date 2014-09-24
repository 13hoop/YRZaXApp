//
//  CustomMoreView.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomMoreViewDelegate <NSObject>

-(void)getSelectIndexPath:(NSIndexPath*)indexPath;

@end

@interface CustomMoreView : UIView

@property(nonatomic,strong)NSString *balance;
@property(nonatomic,strong)id <CustomMoreViewDelegate>more_delegate;

@end
