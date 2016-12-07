//
//  RegisterInfoViewController.m
//  iosapp
//
//  Created by 李萍 on 16/10/10.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "RegisterInfoViewController.h"
#import "Utils.h"
#import "Config.h"

#import "OSCAPI.h"
#import "OSCUserItem.h"

#import "OSCThread.h"
#import "UIDevice+SystemInfo.h"

#import <MJExtension.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>

#define viewHeight [UIScreen mainScreen].bounds.size.height
#define navBarHeight 64
#define affsetHeight 291

@interface RegisterInfoViewController () <UITextFieldDelegate>
{
    CGFloat maxY;
    BOOL isShowKeyboard;
}

@property (nonatomic, assign) BOOL isFMale;//默认性别为男士
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation RegisterInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    
    [self buttonStateEnable];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboardForTap)]];
    self.view.userInteractionEnabled = YES;
    
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    _userNameTextField.tintColor = [UIColor whiteColor];
    _passwordTextField.tintColor = [UIColor whiteColor];
    [_userNameTextField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];

    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gender action
- (IBAction)chooseGenderAction:(UIButton *)sender {
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    if (sender.tag == 1) {//选择性别为男
        [_genderMButton setImage:[UIImage imageNamed:@"btn_gender_male_actived"] forState:UIControlStateNormal];
        [_genderMButton setImage:[UIImage imageNamed:@"btn_gender_male_actived"] forState:UIControlStateHighlighted];
        [_genderFMButton setImage:[UIImage imageNamed:@"btn_gender_female_normal"] forState:UIControlStateNormal];
        [_genderFMButton setImage:[UIImage imageNamed:@"btn_gender_female_normal"] forState:UIControlStateHighlighted];
        _isFMale = NO;
    } else if (sender.tag == 2) {//选择性别为女
        [_genderMButton setImage:[UIImage imageNamed:@"btn_gender_male_normal"] forState:UIControlStateNormal];
        [_genderMButton setImage:[UIImage imageNamed:@"btn_gender_male_normal"] forState:UIControlStateHighlighted];
        [_genderFMButton setImage:[UIImage imageNamed:@"btn_gender_female_actived"] forState:UIControlStateNormal];
        [_genderFMButton setImage:[UIImage imageNamed:@"btn_gender_female_actived"] forState:UIControlStateHighlighted];
        _isFMale = YES;
    } else {//默认性别为男
        [_genderMButton setImage:[UIImage imageNamed:@"btn_gender_male_actived"] forState:UIControlStateNormal];
        [_genderMButton setImage:[UIImage imageNamed:@"btn_gender_male_actived"] forState:UIControlStateHighlighted];
        [_genderFMButton setImage:[UIImage imageNamed:@"btn_gender_female_normal"] forState:UIControlStateNormal];
        [_genderFMButton setImage:[UIImage imageNamed:@"btn_gender_female_normal"] forState:UIControlStateHighlighted];
        _isFMale = NO;
    }
    
}

- (IBAction)highlightedState:(UIButton *)sender {
    _registerButton.backgroundColor = [UIColor colorWithHex:0x14b94d];
}

- (IBAction)outSideState:(UIButton *)sender {
    _registerButton.backgroundColor = [UIColor navigationbarColor];
}

- (void)buttonStateEnable
{
    if (_userNameTextField.text.length > 0 && _passwordTextField.text.length > 0) {
        _registerButton.backgroundColor = [UIColor navigationbarColor];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _registerButton.enabled = YES;
    } else {
        _registerButton.backgroundColor = [UIColor colorWithHex:0x43815c];
        [_registerButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
        _registerButton.enabled = NO;
    }
}

#pragma mark - register action
- (IBAction)genderAction:(UIButton *)sender {
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    _registerButton.backgroundColor = [UIColor navigationbarColor];

    //*
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_ACCOUNT_REGISTER]
      parameters:@{
                   @"username"   : _userNameTextField.text,
                   @"password"   : [Utils sha1:_passwordTextField.text],
                   @"gender"     : _isFMale ? @(2) : @(1),
                   @"phoneToken" : _phoneToken,
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 //注册成功后，直接登录， 保存用户信息，cookie
                 NSDictionary *result = responseObject[@"result"];

                 //注册成功，保存账户名
                 [Config saveOwnAccount:_userNameTextField.text andPassword:@""];
                 
                 OSCUserItem *user = [OSCUserItem mj_objectWithKeyValues:result];
                 
                 [self saveUserInfo:user];
             } else {
                 
                 switch (code) {
                     case 216:
                     {
                         //PhoneToken验证失败（需要重新换取Token值）
                         _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                         [self dismissViewControllerAnimated:YES completion:nil];
                         
                         break;
                     }
                     case 217:
                     {
                         //已有该用户名
                         [Utils setButtonBorder:_userNameView isFail:YES isEditing:NO];
                         break;
                     }
                     case 219:
                     {
                         //密码不合法（最少6位）
                         [Utils setButtonBorder:_passWordView isFail:YES isEditing:NO];
                         break;
                     }
                     default:
                         break;
                 }
             }
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = responseObject[@"message"];
             
             [HUD hideAnimated:YES afterDelay:2];
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:2];
         }];
    //*/
}

- (void)saveUserInfo:(OSCUserItem *)user
{
    [Config saveNewProfile:user];
    
    [OSCThread startPollingNotice];
    
    [self saveCookies];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
    _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
}

#pragma mark - Back view
- (IBAction)backAction:(UIButton *)sender {
    _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - hidden Keyboard
- (void)hiddenKeyboardForTap
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _userNameTextField) {
        [Utils setButtonBorder:_userNameView isFail:NO isEditing:YES];
        [Utils setButtonBorder:_passWordView isFail:NO isEditing:NO];
    } else if (textField == _passwordTextField) {
        [Utils setButtonBorder:_userNameView isFail:NO isEditing:NO];
        [Utils setButtonBorder:_passWordView isFail:NO isEditing:YES];
    }
    
    [self buttonStateEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _userNameTextField || textField == _passwordTextField) {

        [Utils setButtonBorder:_userNameView isFail:NO isEditing:NO];
        [Utils setButtonBorder:_passWordView isFail:NO isEditing:NO];
        
    }
    [self buttonStateEnable];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self buttonStateEnable];
    
    if (textField == _userNameTextField) {
        if (range.length == 0 && range.location == 0 && _passwordTextField.text.length >= 6) {
            _registerButton.backgroundColor = [UIColor navigationbarColor];
            [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _registerButton.enabled = YES;
        } else if (range.length == 1 && range.location == 0) {
            _registerButton.backgroundColor = [UIColor colorWithHex:0x43815c];
            [_registerButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
            _registerButton.enabled = NO;
        }
    } else if (textField == _passwordTextField) {
        if (range.length == 0 && range.location >= 5 && _userNameTextField.text.length > 0) {
            _registerButton.backgroundColor = [UIColor navigationbarColor];
            [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _registerButton.enabled = YES;
        } else if (range.length == 1 && range.location <= 5) {
            _registerButton.backgroundColor = [UIColor colorWithHex:0x43815c];
            [_registerButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
            _registerButton.enabled = NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _registerButton.backgroundColor = [UIColor colorWithHex:0x43815c];
    [_registerButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
    _registerButton.enabled = NO;
    
    return YES;
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

- (void)keyboardAction:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval timeInt;
    [animationDuration getValue:&timeInt];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat keyBoradHeight = keyboardRect.size.height;
    maxY = self.userNameView.frame.origin.y - ((viewHeight - keyBoradHeight + navBarHeight - affsetHeight) * 0.5);
    maxY = viewHeight > 550 ? maxY : 100;
    
    if (notification.name == UIKeyboardWillShowNotification) {
        if (isShowKeyboard == NO) {
            [UIView animateWithDuration:timeInt
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 _userNameView.frame = [self startAnimationForEditing:_userNameView];
                                 _passWordView.frame = [self startAnimationForEditing:_passWordView];
                                 _genderMButton.frame = [self startAnimationForEditing:_genderMButton];
                                 _genderFMButton.frame = [self startAnimationForEditing:_genderFMButton];
                                 _genderMLabel.frame = [self startAnimationForEditing:_genderMLabel];
                                 _genderFMLabel.frame = [self startAnimationForEditing:_genderFMLabel];
                                 _registerButton.frame = [self startAnimationForEditing:_registerButton];
                                 
                                 _nameToTopHeight.constant = 109 - maxY;
                                 
                             } completion:^(BOOL finished) {
                                 isShowKeyboard = YES;
                             }];
            
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
            [self.view addGestureRecognizer:_tap];
        }
        
        
    } else if (notification.name == UIKeyboardWillHideNotification) {
        [UIView animateWithDuration:-timeInt
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _userNameView.frame = [self stopAnimationForEditing:_userNameView];
                             _passWordView.frame = [self stopAnimationForEditing:_passWordView];
                             _genderMButton.frame = [self stopAnimationForEditing:_genderMButton];
                             _genderFMButton.frame = [self stopAnimationForEditing:_genderFMButton];
                             _genderMLabel.frame = [self stopAnimationForEditing:_genderMLabel];
                             _genderFMLabel.frame = [self stopAnimationForEditing:_genderFMLabel];
                             _registerButton.frame = [self stopAnimationForEditing:_registerButton];
                             
                             _nameToTopHeight.constant = 109;
                         } completion:^(BOOL finished) {
                             isShowKeyboard = NO;
                         }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - editing animation view
- (CGRect)startAnimationForEditing:(UIView *)sender
{
    CGSize size = sender.frame.size;
    CGPoint point = sender.frame.origin;
    
    return CGRectMake(point.x, point.y - maxY, size.width, size.height);
}

- (CGRect)stopAnimationForEditing:(UIView *)sender
{
    CGSize size = sender.frame.size;
    CGPoint point = sender.frame.origin;
    
    return CGRectMake(point.x, point.y + maxY, size.width, size.height);
}

@end
