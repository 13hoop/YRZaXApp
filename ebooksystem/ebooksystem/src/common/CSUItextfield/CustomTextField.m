//
//  CustomTextField.m
//  ebooksystem
//
//  Created by wanghaoyu on 14-10-17.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import "CustomTextField.h"
#import "UIColor+Hex.h"
@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
//控制placeHolder的位置，左右缩20
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    
    //return CGRectInset(bounds, 20, 0);
    CGRect inset = CGRectMake(bounds.origin.x+17, bounds.origin.y+13, bounds.size.width -10, bounds.size.height);//更好理解些
    return inset;
}
//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    //return CGRectInset(bounds, 50, 0);
    CGRect inset = CGRectMake(bounds.origin.x+14, bounds.origin.y, bounds.size.width -10, bounds.size.height);//更好理解些
    
    return inset;
    
}
//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    //return CGRectInset( bounds, 10 , 0 );
    
    CGRect inset = CGRectMake(bounds.origin.x+14, bounds.origin.y, bounds.size.width -10, bounds.size.height);
    return inset;
}
//控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
//    [[UIColor orangeColor] setFill];
    UIColor *color=[UIColor colorWithHexString:@"#7d7c7c" alpha:1];
    [color setFill];
    
    [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:14.0f]];
}

@end
