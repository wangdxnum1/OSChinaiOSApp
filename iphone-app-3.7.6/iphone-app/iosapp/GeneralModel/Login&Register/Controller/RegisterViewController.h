//
//  RegisterViewController.h
//  iosapp
//
//  Created by 李萍 on 16/10/10.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextField;
@property (weak, nonatomic) IBOutlet UIButton *captchaButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UIView *captchaView;
@property (weak, nonatomic) IBOutlet UIImageView *oscLogView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameToTopHeight;
@property (weak, nonatomic) IBOutlet UIImageView *bakImageView;

@end
