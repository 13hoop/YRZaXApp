//
//  UMContactViewController.h
//  Demo
//
//  Created by liuyu on 4/2/13.
//  Copyright (c) 2013 iOS@Umeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMContactViewControllerDelegate;

@interface UMContactViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic, retain) IBOutlet UIView *backgroundView;
@property(nonatomic,retain)IBOutlet UITextView *textView;
@property(nonatomic,strong)IBOutlet UITextField *nameText;
@property(nonatomic,strong)IBOutlet UITextField *contactInfo;
@property(nonatomic,strong)IBOutlet UITextField *date;
@property(nonatomic,strong)IBOutlet UITextField *email;
@property(nonatomic,strong)IBOutlet UITextField *project;
@property(nonatomic,strong)IBOutlet UIButton *cancelButton;
@property(nonatomic,strong)IBOutlet UIButton *okButton;
-(IBAction)okButton:(id)sender;
-(IBAction)cancelButton:(id)sender;
@property(nonatomic, assign) id <UMContactViewControllerDelegate> delegate;

@end

@protocol UMContactViewControllerDelegate <NSObject>

@optional

- (void)updateContactInfo:(UMContactViewController *)controller contactInfo:(NSString *)info andWithReamrkInfo:(NSString *)remarkInfo;

@end