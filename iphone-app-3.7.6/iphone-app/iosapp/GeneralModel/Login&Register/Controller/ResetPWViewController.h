//
//  ResetPWViewController.h
//  iosapp
//
//  Created by 李萍 on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPWViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIView *subView;

@property (nonatomic, copy) NSString *phoneToken;//手机返回的验证码

@property (weak, nonatomic) IBOutlet UIImageView *bakImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameToTopHeight;

@end
