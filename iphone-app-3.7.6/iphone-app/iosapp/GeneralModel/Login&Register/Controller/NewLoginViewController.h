//
//  NewLoginViewController.h
//  iosapp
//
//  Created by 李萍 on 16/10/10.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetButton;

@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passWordView;
@property (weak, nonatomic) IBOutlet UIImageView *oscLogView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameToTopHeight;

@property (weak, nonatomic) IBOutlet UIImageView *bakImageView;

@end
