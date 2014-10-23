//
//  ProgressOverlayViewController.h
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum {
//    PROGRESS_VIEW_INDETERMINATE = 0,
//    PROGRESS_VIEW_DETERMINATE_CIRCULAR,
//    PROGRESS_VIEW_DETERMINATE_HORIZONTAL_BAR,
//    PROGRESS_VIEW_INDETERMINATE_SMALL,
//    PROGRESS_VIEW_INDETERMINATE_SMALL_DEFAULT,
//    PROGRESS_VIEW_CHECKMARK,
//    PROGRESS_VIEW_CROSS,
//    PROGRESS_VIEW_WITH_LONG_TITLE_LABEL,
//    PROGRESS_VIEW_SMALL_PROGRESSVIEW_WITH_LONG_TITLE_LABEL
//} ProgressViewType;

@protocol ProgressOverlayViewControllerDelegate;



@interface ProgressOverlayViewController : UIViewController

@property (nonatomic, weak) id<ProgressOverlayViewControllerDelegate> delegate;

#pragma mark - methods
- (void)showIndeterminateProgressView:(id)sender;
- (void)showDeterminateCircularProgressView:(id)sender;
- (void)showDeterminateHorizontalBarProgressView:(id)sender;
- (void)showIndeterminateSmallProgressView:(id)sender;
- (void)showIndeterminateSmallDefaultProgressView:(id)sender;
- (void)showCheckmarkProgressView:(id)sender;
- (void)showCrossProgressView:(id)sender;
- (void)showProgressViewWithLongTitleLabelText:(id)sender;
- (void)showSmallProgressViewWithLongTitleLabelText:(NSString *)text;

- (void)updateProgress:(NSInteger)progressVal;
- (void)dismissProgressView;

@end



@protocol ProgressOverlayViewControllerDelegate <NSObject>

- (UIView *)viewForProgressOverlay;

@end
