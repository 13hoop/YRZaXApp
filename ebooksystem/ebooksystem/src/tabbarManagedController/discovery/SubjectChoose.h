//
//  SubjectChoose.h
//  ebooksystem
//
//  Created by wanghaoyu on 15/2/7.
//  Copyright (c) 2015年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SubjectChooseDelegate <NSObject>

- (void)setUserSelectedResult:(NSString *)result;

@end

@interface SubjectChoose : UIView

@property (nonatomic,weak) id<SubjectChooseDelegate> userSelectedDelegate;

@end
