//
//  RegisterInfoViewController.h
//  iosapp
//
//  Created by 李萍 on 16/10/10.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (weak, nonatomic) IBOutlet UIButton *genderMButton;
@property (weak, nonatomic) IBOutlet UIButton *genderFMButton;

@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passWordView;

@property (weak, nonatomic) IBOutlet UIView *genderMLabel;
@property (weak, nonatomic) IBOutlet UIView *genderFMLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameToTopHeight;

@property (nonatomic, copy) NSString *phoneToken;//手机返回的验证码

@property (weak, nonatomic) IBOutlet UIImageView *bakImageView;

@end
