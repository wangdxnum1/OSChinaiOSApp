//
//  FoundPWViewController.h
//  iosapp
//
//  Created by 李萍 on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoundPWViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *captchaButton;

@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UIView *captchaView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameToTopHeight;

@property (weak, nonatomic) IBOutlet UIImageView *bakImageView;

@end
