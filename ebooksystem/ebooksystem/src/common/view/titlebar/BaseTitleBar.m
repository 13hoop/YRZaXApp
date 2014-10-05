//
//  CustomNavigationBar.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-22.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "BaseTitleBar.h"
#import "QBTitleView.h"


@interface BaseTitleBar()


@property (nonatomic, copy)QBTitleView *titleView;


@end


@implementation BaseTitleBar


@synthesize titleView = _titleView;
@synthesize titleText = _titleText;

@synthesize leftView = _leftView;
@synthesize rightView = _rightView;


#pragma mark - properties
- (QBTitleView *)titleView {
    if (_titleView == nil) {
        _titleView = [[QBTitleView alloc] initWithFrame:CGRectMake(0, 0, 170, 44)];
//        [_titleView setBackgroundColor:[UIColor redColor]]; // test only
        [self addSubview:_titleView];
    }
    
    return _titleView;
}

- (void)setTitleText:(NSString *)titleText {
    [self.titleView setTitle:titleText];
}

- (void)setTitleImage:(UIImage *)titleImage {
    [self.titleView setImage:titleImage];
}

- (void)setTitleHighlightedImage:(UIImage *)titleHighlightedImage {
    [self.titleView setHighlightedImage:titleHighlightedImage];
}

- (void)setLeftView:(UIView *)leftView {
    if (_leftView != nil) {
        [_leftView removeFromSuperview];
    }
    
    _leftView = leftView;
    [self addSubview:_leftView];
    
    [self update];
}

- (void)setRightView:(UIView *)rightView {
    if (_rightView != nil) {
        [_rightView removeFromSuperview];
    }
    
    _rightView = rightView;
    [self addSubview:_rightView];
    
    [self update];
}

#pragma mark - ui
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)update {
    CGRect wholeFrame = self.frame;
    CGRect leftViewFrame = self.leftView.frame;
    CGRect rightViewFrame = self.rightView.frame;
    
    CGRect titleViewFrame = CGRectMake(leftViewFrame.origin.x + leftViewFrame.size.width,
                                       0,
                                       //wholeFrame.size.width - leftViewFrame.size.width - rightViewFrame.size.width,
                                       rightViewFrame.origin.x - leftViewFrame.origin.x - leftViewFrame.size.width,
                                       wholeFrame.size.height);
    [self.titleView setFrame:titleViewFrame];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
//        self.titleLable.text=[self valueForKeyPath:@"title"];
        
    }
}

@end
