//
//  FoundPWViewController.m
//  iosapp
//
//  Created by 李萍 on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "FoundPWViewController.h"
#import "ResetPWViewController.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "ResetPWViewController.h"
#import "UIDevice+SystemInfo.h"

#import <MJExtension.h>
#import <ReactiveCocoa.h>
#import <AFNetworking.h>
#import <MBProgressHUD.h>

@import SafariServices ;
#define viewHeight [UIScreen mainScreen].bounds.size.height
#define navBarHeight 64
#define affsetHeight 221

#define MAX_PHONENUMBER_LENGTH 11

@interface FoundPWViewController () <UITextFieldDelegate>
{
    CGFloat maxY;
    BOOL isShowKeyboard;
}

@property (nonatomic, copy) NSString *phoneToken;//手机返回的验证码
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation FoundPWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"找回密码";
    
    RACSignal *valid = [RACSignal combineLatest:@[_phoneNumberTextField.rac_textSignal]
                                         reduce:^(NSString *phoneNumber) {
                                             return @(phoneNumber.length == 11);
                                         }];
    RAC(_captchaButton, enabled) = valid;
    RAC(_captchaButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1: @0.4;
    }];
    
    [self buttonStateEnable];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboardForTap)]];
    self.view.userInteractionEnabled = YES;
    
    _captchaButton.layer.borderWidth = 1;
    _captchaButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _phoneNumberTextField.delegate = self;
    _captchaTextField.delegate = self;
    _phoneNumberTextField.tintColor = [UIColor whiteColor];
    _captchaTextField.tintColor = [UIColor whiteColor];
    [_phoneNumberTextField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];
    [_captchaTextField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];
    
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

#pragma mark - Back view
- (IBAction)backAction:(UIButton *)sender {
    _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - hidden Keyboard
- (void)hiddenKeyboardForTap
{
    [_phoneNumberTextField resignFirstResponder];
    [_captchaTextField resignFirstResponder];
}

#pragma mark - mailBoxAction
- (void)mailBoxAction
{
    [_phoneNumberTextField resignFirstResponder];
    [_captchaTextField resignFirstResponder];
    
    SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.oschina.net/home/reset-pwd"]];
    webviewController.hidesBottomBarWhenPushed = YES;
    [self presentViewController:webviewController animated:YES completion:nil];
}

#pragma mark - captcha action
- (IBAction)captchaAction:(UIButton *)sender {
    [_phoneNumberTextField resignFirstResponder];
    [_captchaTextField resignFirstResponder];
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_PHONE_SEND_CODE]
      parameters:@{
                   @"phone"    : _phoneNumberTextField.text,
                   @"intent"   : @(2),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 [self openCountdown];//倒计时
             } else {
                 switch (code) {
                     case 214:
                     {
                         //手机格式不合法
                         [Utils setButtonBorder:_phoneNumberView isFail:YES isEditing:NO];
                         break;
                     }
                     case 220:
                     {
                         //手机号未注册
                         [Utils setButtonBorder:_phoneNumberView isFail:YES isEditing:NO];
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
             //             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:2];
         }];
}

#pragma mark - 开启倒计时效果
-(void)openCountdown{
    
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [_captchaButton setTitle:@"重新发送" forState:UIControlStateNormal];
                [_captchaButton setTitleColor:[UIColor colorWithHex:0xffffff] forState:UIControlStateNormal];
                _captchaButton.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
                _captchaButton.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [_captchaButton setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
                [_captchaButton setTitleColor:[UIColor colorWithHex:0xdededf] forState:UIControlStateNormal];
                _captchaButton.layer.borderColor = [UIColor colorWithHex:0xdededf].CGColor;
                _captchaButton.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

- (IBAction)highlightedState:(UIButton *)sender {
    _nextButton.backgroundColor = [UIColor colorWithHex:0x14b94d];
}

- (IBAction)outSideState:(UIButton *)sender {
    _nextButton.backgroundColor = [UIColor navigationbarColor];
}

- (void)buttonStateEnable
{
    if (_phoneNumberTextField.text.length == MAX_PHONENUMBER_LENGTH && _captchaTextField.text.length > 0) {
        _nextButton.backgroundColor = [UIColor navigationbarColor];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _nextButton.enabled = YES;
    } else {
        _nextButton.backgroundColor = [UIColor colorWithHex:0x43815c];
        [_nextButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
        _nextButton.enabled = NO;
    }
}

#pragma mark - next action
- (IBAction)nextAction:(id)sender {
    [_phoneNumberTextField resignFirstResponder];
    [_captchaTextField resignFirstResponder];
    
    _nextButton.backgroundColor = [UIColor navigationbarColor];
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_PHONE_VALIDATE]
      parameters:@{
                   @"phone"    : _phoneNumberTextField.text,
                   @"code"     : _captchaTextField.text,
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 //
                 NSDictionary *result = responseObject[@"result"];
                 _phoneToken = result[@"token"];
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
                 ResetPWViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"ResetPWViewController"];
                 controller.phoneToken = _phoneToken;
                 [self presentViewController:controller animated:YES completion:nil];
             } else {
                 switch (code) {
                     case 214:
                     {
                         //手机格式不合法
                         [Utils setButtonBorder:_phoneNumberView isFail:YES isEditing:NO];
                         break;
                     }
                     case 215:
                     {
                         //验证码错误
                         [Utils setButtonBorder:_captchaView isFail:YES isEditing:NO];
                         break;
                     }
                     default:
                         break;
                 }
                 
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = responseObject[@"message"];
                 
                 [HUD hideAnimated:YES afterDelay:2];
             }
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             //             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:2];
         }];

}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _phoneNumberTextField) {
        [Utils setButtonBorder:_phoneNumberView isFail:NO isEditing:YES];
        [Utils setButtonBorder:_captchaView isFail:NO isEditing:NO];
    } else if (textField == _captchaTextField) {
        [Utils setButtonBorder:_phoneNumberView isFail:NO isEditing:NO];
        [Utils setButtonBorder:_captchaView isFail:NO isEditing:YES]; 
    }
    [self buttonStateEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _captchaTextField) {
        
        [Utils setButtonBorder:_captchaView isFail:NO isEditing:NO];
    }
    
    if (textField == _phoneNumberTextField) {
        if (_phoneNumberTextField.text.length > 0) {
            if ([Utils validateMobile:_phoneNumberTextField.text]) {
                [Utils setButtonBorder:_phoneNumberView isFail:NO isEditing:NO];
                _captchaButton.enabled = YES;
            } else {
                [Utils setButtonBorder:_phoneNumberView isFail:YES isEditing:NO];
                _captchaButton.enabled = NO;
            }
        } else {
            [Utils setButtonBorder:_phoneNumberView isFail:NO isEditing:NO];
        }
        
    }
    [self buttonStateEnable];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self buttonStateEnable];
    
    if (textField == _captchaTextField) {
        if (range.length == 0 && range.location == 0) {
            _nextButton.backgroundColor = [UIColor navigationbarColor];
            [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _nextButton.enabled = YES;
        } else if (range.length == 1 && range.location == 0) {
            _nextButton.backgroundColor = [UIColor colorWithHex:0x43815c];
            [_nextButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
            _nextButton.enabled = NO;
        }
        
        return YES;
    } else if (textField == _phoneNumberTextField) {
        if (_phoneNumberTextField.text.length >= MAX_PHONENUMBER_LENGTH) {
            return NO;
            
        } else if (_phoneNumberTextField.text.length == MAX_PHONENUMBER_LENGTH - 1 && _captchaTextField.text.length > 0) {
            _nextButton.backgroundColor = [UIColor navigationbarColor];
            [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _nextButton.enabled = YES;
            
            return YES;
        } else {
            return YES;
        }
        
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _nextButton.backgroundColor = [UIColor colorWithHex:0x43815c];
    [_nextButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
    _nextButton.enabled = NO;
    
    return YES;
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_phoneNumberTextField resignFirstResponder];
    [_captchaTextField resignFirstResponder];
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
    maxY = self.phoneNumberView.frame.origin.y - ((viewHeight - keyBoradHeight + navBarHeight - affsetHeight) * 0.5);
    maxY = viewHeight > 550 ? maxY : 120;
    
    if (notification.name == UIKeyboardWillShowNotification) {
        if (isShowKeyboard == NO) {
            [UIView animateWithDuration:timeInt
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 _phoneNumberView.frame = [self startAnimationForEditing:_phoneNumberView];
                                 _captchaView.frame = [self startAnimationForEditing:_captchaView];
                                 _nextButton.frame = [self startAnimationForEditing:_nextButton];
                                 
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
                             _phoneNumberView.frame = [self stopAnimationForEditing:_phoneNumberView];
                             _captchaView.frame = [self stopAnimationForEditing:_captchaView];
                             _nextButton.frame = [self stopAnimationForEditing:_nextButton];
                             
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
