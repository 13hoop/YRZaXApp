//
//  ProgressOverlayViewController.m
//  ebooksystem
//
//  Created by zhenghao on 10/23/14.
//  Copyright (c) 2014 sanweishuku. All rights reserved.
//

#import "ProgressOverlayViewController.h"

#import "MRProgress.h"

@interface ProgressOverlayViewController()
{
    MRProgressOverlayView *progressView;
}

- (UIView *)rootView;

- (void)simulateProgressView:(MRProgressOverlayView *)progressView;
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay;

@end




@implementation ProgressOverlayViewController

#pragma mark - properties



#pragma mark - methods
- (UIView *)rootView {
    return self.delegate.viewForProgressOverlay;
}

- (void)showIndeterminateProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView = [MRProgressOverlayView new];
    [self.rootView addSubview:progressView];
    [progressView show:YES];
    [self performBlock:^{
        [progressView dismiss:YES];
    } afterDelay:2.0];
}

- (void)showDeterminateCircularProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView = [MRProgressOverlayView new];
    progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
    [self.rootView addSubview:progressView];
    [self simulateProgressView:progressView];
}

- (void)showDeterminateHorizontalBarProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView = [MRProgressOverlayView new];
    progressView.mode = MRProgressOverlayViewModeDeterminateHorizontalBar;
    [self.rootView addSubview:progressView];
    [self simulateProgressView:progressView];
}

- (void)showIndeterminateSmallProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView new];
    progressView = [MRProgressOverlayView new];
    progressView.mode = MRProgressOverlayViewModeIndeterminateSmall;
    [self.rootView addSubview:progressView];
    [progressView show:YES];
    [self performBlock:^{
        [progressView dismiss:YES];
    } afterDelay:2.0];
}

- (void)showIndeterminateSmallDefaultProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView.mode = MRProgressOverlayViewModeIndeterminateSmallDefault;
    [self performBlock:^{
        [MRProgressOverlayView dismissOverlayForView:self.rootView animated:YES];
    } afterDelay:2.0];
}

- (void)showCheckmarkProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView.mode = MRProgressOverlayViewModeCheckmark;
    progressView.titleLabelText = @"Succeed";
    [self performBlock:^{
        [progressView dismiss:YES];
    } afterDelay:2.0];
}

- (void)showCrossProgressView:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView.mode = MRProgressOverlayViewModeCross;
    progressView.titleLabelText = @"Failed";
    [self performBlock:^{
        [progressView dismiss:YES];
    } afterDelay:2.0];
}

- (void)showProgressViewWithLongTitleLabelText:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView.titleLabelText = @"Please stay awake!\nDo not press anykey while loading.";
    [self performBlock:^{
        [progressView dismiss:YES];
    } afterDelay:2.0];
}

//- (void)showSmallProgressViewWithLongTitleLabelText:(id)sender {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
//    progressView.mode = MRProgressOverlayViewModeIndeterminateSmall;
//    progressView.titleLabelText = @"Please stay awake!";
//    [self performBlock:^{
//        [progressView dismiss:YES];
//    } afterDelay:2.0];
//}

- (void)showSmallProgressViewWithLongTitleLabelText:(NSString *)text {
//    MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView = [MRProgressOverlayView showOverlayAddedTo:self.rootView animated:YES];
    progressView.mode = MRProgressOverlayViewModeIndeterminateSmall;
    progressView.titleLabelText = text;
//    [self performBlock:^{
//        [progressView dismiss:YES];
//    } afterDelay:2.0];
}

- (void)updateProgress:(NSInteger)progressVal {
    if (progressView) {
        [progressView setProgress:progressVal animated:YES];
    }
}

- (void)dismissProgressView {
    if (progressView) {
        [progressView dismiss:YES];
    }
}

- (void)showAlertView:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Native Alert View" message:@"Just to compare blur effects." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)simulateProgressView:(MRProgressOverlayView *)progressView {
    static int i=0;
    [progressView show:YES];
    [self performBlock:^{
        [progressView setProgress:0.2 animated:YES];
        [self performBlock:^{
            [progressView setProgress:0.3 animated:YES];
            [self performBlock:^{
                [progressView setProgress:0.5 animated:YES];
                [self performBlock:^{
                    [progressView setProgress:0.4 animated:YES];
                    [self performBlock:^{
                        [progressView setProgress:0.8 animated:YES];
                        [self performBlock:^{
                            [progressView setProgress:1.0 animated:YES];
                            [self performBlock:^{
                                if (++i%2==1) {
                                    progressView.mode = MRProgressOverlayViewModeCheckmark;
                                    progressView.titleLabelText = @"Succeed";
                                } else {
                                    progressView.mode = MRProgressOverlayViewModeCross;
                                    progressView.titleLabelText = @"Failed";
                                }
                                [self performBlock:^{
                                    [progressView dismiss:YES];
                                } afterDelay:0.5];
                            } afterDelay:1.0];
                        } afterDelay:0.33];
                    } afterDelay:0.2];
                } afterDelay:0.1];
            } afterDelay:0.1];
        } afterDelay:0.5];
    } afterDelay:0.33];
}

- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
