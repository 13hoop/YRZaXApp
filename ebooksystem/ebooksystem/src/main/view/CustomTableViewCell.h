//
//  CustomTableViewCell.h
//  ebooksystem
//
//  Created by wanghaoyu on 14-9-25.
//  Copyright (c) 2014年 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property(nonatomic,strong)UIView *backgroundview;
@property(nonatomic,strong)UIImageView *bookImage;
@property(nonatomic,strong)UILabel *titleLable;
@property(nonatomic,strong)UILabel *contentLable;
@property(nonatomic,assign)float height;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withHeight:(float)height;
@end
