//
//  SubjectTableViewCell.h
//  ebooksystem
//
//  Created by zhenghao on 10/4/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectTableViewCell : UITableViewCell

#pragma mark - outlets
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

@end
