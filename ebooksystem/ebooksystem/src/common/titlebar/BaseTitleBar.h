//
//  CustomNavigationBar.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - title bar delegate
@protocol BaseTitleBarDelegate <NSObject>

//@optional

@end


#pragma mark -
#pragma mark - title bar
@interface BaseTitleBar : UIView

#pragma mark - properties
// background
//@property (nonatomic, copy) UIColor *bgColor;

// title(middle)
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, retain) UIImage *titleImage;
@property (nonatomic, retain) UIImage *titleHighlightedImage;

// left
@property (nonatomic, strong) UIView *leftView;

// right
@property (nonatomic, strong) UIView *rightView;


// delegate
@property (nonatomic, strong) id<BaseTitleBarDelegate> delegate;


@end
