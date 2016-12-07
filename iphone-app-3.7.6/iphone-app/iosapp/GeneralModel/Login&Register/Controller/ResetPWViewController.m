//
//  ResetPWViewController.m
//  iosapp
//
//  Created by 李萍 on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ResetPWViewController.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "Config.h"
#import "UIDevice+SystemInfo.h"

#import <MJExtension.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>

#define viewHeight [UIScreen mainScreen].bounds.size.height
#define navBarHeight 64
#define affsetHeight 221

@interface ResetPWViewController () <UITextFieldDelegate>
{
    CGFloat maxY;
}
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation ResetPWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"重置密码";
    
    [self buttonStateEnable];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboardForTap)]];
    self.view.userInteractionEnabled = YES;
    
    _textField.delegate = self;
    _textField.tintColor = [UIColor whiteColor];
    [_textField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Back view
- (IBAction)backAction:(UIButton *)sender {
    _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - hidden Keyboard
- (void)hiddenKeyboardForTap
{
    [_textField resignFirstResponder];
}

- (IBAction)highlightedState:(UIButton *)sender {
    _resetButton.backgroundColor = [UIColor colorWithHex:0x14b94d];
}

- (IBAction)outSideState:(UIButton *)sender {
    _resetButton.backgroundColor = [UIColor navigationbarColor];
}

- (void)buttonStateEnable
{
    if (_textField.text.length > 5) {
        _resetButton.backgroundColor = [UIColor navigationbarColor];
        [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _resetButton.enabled = YES;
    } else {
        _resetButton.backgroundColor = [UIColor colorWithHex:0x43815c];
        [_resetButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
        _resetButton.enabled = NO;
    }
}

#pragma mark - reset PassWord Action

- (IBAction)resetPassWordAction:(UIButton *)sender {
    [_textField resignFirstResponder];
    
    _resetButton.backgroundColor = [UIColor navigationbarColor];
    
    //*
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_ACCOUNT_PASSWORD_FORGET]
      parameters:@{
                   @"password"   : [Utils sha1:_textField.text],
                   @"phoneToken" : _phoneToken,
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 //重置成功后，登录界面重新登录

                 //调至登录页面
                 _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                 [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                switch (code) {
                    case 216:
                    {
                        //PhoneToken验证失败（需要重新换取Token值）
                        _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        [self dismissViewControllerAnimated:YES completion:nil];
                        break;
                    }
                    case 219:
                    {
                        //密码不合法（最少6位）
                        [Utils setButtonBorder:_subView isFail:YES isEditing:NO];
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

CGFloat maxY;
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _textField) {
        [Utils setButtonBorder:_subView isFail:NO isEditing:YES];
    }
    [self buttonStateEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textField) {
        [Utils setButtonBorder:_subView isFail:NO isEditing:NO];
    }
    [self buttonStateEnable];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self buttonStateEnable];
    
    if (range.length == 0 && range.location >= 5) {
        _resetButton.backgroundColor = [UIColor navigationbarColor];
        [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _resetButton.enabled = YES;
    } else if (range.length == 1 && range.location <= 5) {
        _resetButton.backgroundColor = [UIColor colorWithHex:0x43815c];
        [_resetButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
        _resetButton.enabled = NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _resetButton.backgroundColor = [UIColor colorWithHex:0x43815c];
    [_resetButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
    _resetButton.enabled = NO;
    
    return YES;
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_textField resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

- (void)keyboardWillShow:(NSNotification *)nsNotification
{
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *animationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval timeInt;
    [animationDuration getValue:&timeInt];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat keyBoradHeight = keyboardRect.size.height;
    maxY = self.subView.frame.origin.y - ((viewHeight - keyBoradHeight + navBarHeight - affsetHeight) * 0.5);
    maxY = viewHeight > 550 ? maxY : 85;
    
    [UIView animateWithDuration:timeInt
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _subView.frame = [self startAnimationForEditing:_subView];
                         _resetButton.frame = [self startAnimationForEditing:_resetButton];
                         
                     } completion:nil];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *animationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval timeInt;
    [animationDuration getValue:&timeInt];
    
    [UIView animateWithDuration:timeInt
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _subView.frame = [self stopAnimationForEditing:_subView];
                         _resetButton.frame = [self stopAnimationForEditing:_resetButton];
                         
                     } completion:nil];
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
