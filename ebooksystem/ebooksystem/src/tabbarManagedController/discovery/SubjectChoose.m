//
//  SubjectChoose.m
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/7.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import "SubjectChoose.h"

#define LABLE_WIDTH 200
@implementation SubjectChoose

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self createUI];
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backgroundColor = [UIColor whiteColor];
    
}

- (void)createUI {
    //
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    //提示lable
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake((width - LABLE_WIDTH)/2, 40, LABLE_WIDTH, 40)];
    lable.text = @"请选择你将要学习的内容：";
    lable.font = [UIFont systemFontOfSize:16.0f];
    lable.textColor = [UIColor redColor];
    [self addSubview:lable];
    //创建选择按钮
    NSArray *titleArr = @[@"考研",@"教师资格证"];
    for (NSUInteger i = 0; i<2; i++) {
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((width - 200)/2, 100+i*100, 200, 40)];
        [btn setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        btn.tag = i+1000;
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)btnDown:(UIButton *)btn {
    if (btn.tag == 1000) {
        [self.userSelectedDelegate setUserSelectedResult:@"考研"];
    }
    else {
        [self.userSelectedDelegate setUserSelectedResult:@"教师资格证"];
    }
    
}

@end
