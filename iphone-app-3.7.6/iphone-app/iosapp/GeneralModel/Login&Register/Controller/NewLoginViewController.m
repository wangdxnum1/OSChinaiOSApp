//
//  NewLoginViewController.m
//  iosapp
//
//  Created by 李萍 on 16/10/10.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewLoginViewController.h"
#import "FoundPWViewController.h"
#import "Config.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "OSCAPI.h"
#import "UIDevice+SystemInfo.h"
#import "OSCUserItem.h" //user
#import "OSCThread.h"

#import <MJExtension.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <ReactiveCocoa.h>
#import <CommonCrypto/CommonDigest.h>

#define viewHeight [UIScreen mainScreen].bounds.size.height
#define navBarHeight 64
#define affsetHeight 250

static BOOL isUpThirdLoginView;
@interface NewLoginViewController () <UITextFieldDelegate, TencentSessionDelegate, WeiboSDKDelegate, WXApiDelegate>
{
    CGFloat maxY;
    BOOL isShowKeyboard;
}

@property (nonatomic, weak) IBOutlet UIView *thirdLoginView;
@property (nonatomic, weak) UIView *alphaView;
@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *weChatButtonRight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *weChatButtonLeft;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *weChatButtonWidth;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end

@implementation NewLoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (CGRectGetHeight(self.view.frame) < 500) {
        _nameToTopHeight.constant = 85;
        _oscLogView.hidden = YES;
    } else {
        _nameToTopHeight.constant = 173;//113;
        _oscLogView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"登录";
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.loginDelegate = self;
    
    [self setTextViewStyle];

    if (![WXApi isWXAppInstalled]) {
        _weChatButtonWidth.constant = 0;
    }
//目前移动应用上微信登录只提供原生的登录方式，需要用户安装微信客户端才能配合使用
//    if (![TencentOAuth iphoneQQInstalled]) {
//        _thirdLoginView.QQButton.hidden = YES;
//    }
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    [_userNameTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_passwordTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set textField style
- (void)setTextViewStyle
{
    NSArray *accountAndPassword = [Config getOwnAccountAndPassword];
    _userNameTextField.text = accountAndPassword? accountAndPassword[0] : @"";
    
    [self buttonStateEnable];
    
//    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboardForTap)]];
//    self.view.userInteractionEnabled = YES;
    
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    _userNameTextField.tintColor = [UIColor whiteColor];
    _passwordTextField.tintColor = [UIColor whiteColor];
    [_userNameTextField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField setValue:[UIColor colorWithHex:0xdededf] forKeyPath:@"_placeholderLabel.textColor"];
    _registerButton.layer.borderWidth = 1;
    _registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_thirdLoginButton setImage:[UIImage imageNamed:@"bg_login_thirdpart"] forState:UIControlStateHighlighted];
    
}

#pragma mark - Back view
- (IBAction)backAction:(UIButton *)sender {
    _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)highlightedState:(UIButton *)sender {
    if (sender == _loginButton) {
        _loginButton.backgroundColor = [UIColor colorWithHex:0x14b94d];
        
    } else if (sender == _registerButton){
        _registerButton.backgroundColor = [UIColor colorWithHex:0xffffff alpha:0.1];
    }
}

- (IBAction)outSideState:(UIButton *)sender {
    if (sender == _loginButton) {
        _loginButton.backgroundColor = [UIColor navigationbarColor];
        
    } else if (sender == _registerButton){
        _registerButton.backgroundColor = [UIColor clearColor];
        
    }
}

- (void)buttonStateEnable
{
    if (_userNameTextField.text.length > 0 && _passwordTextField.text.length > 5) {
        _loginButton.backgroundColor = [UIColor navigationbarColor];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.enabled = YES;
    } else {
        _loginButton.backgroundColor = [UIColor colorWithHex:0x43815c];
        [_loginButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
        _loginButton.enabled = NO;
    }
}

#pragma mark - login
- (IBAction)loginAction:(UIButton *)sender {
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    _loginButton.backgroundColor = [UIColor navigationbarColor];

    [Config saveOwnAccount:_userNameTextField.text andPassword:@""];
    

    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_ACCOUNT_LOGIN]
      parameters:@{
                   @"account"   : _userNameTextField.text,
                   @"password"  : [Utils sha1:_passwordTextField.text],
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 NSDictionary *result = responseObject[@"result"];
                 OSCUserItem *user = [OSCUserItem mj_objectWithKeyValues:result];
                 
                 [self saveUserInfo:user];
             } else {
                 NSString *message = responseObject[@"message"];
                 switch (code) {
                     case 211:
                     {
                         //用户名错误
                         [Utils setButtonBorder:_userNameView isFail:YES isEditing:NO];
                         break;
                     }
                     case 212:
                     {
                         //密码错误
                         [Utils setButtonBorder:_passWordView isFail:YES isEditing:NO];
                         message = @"用户名或密码错误";
                         break;
                     }
                     default:
                         break;
                 }
                 
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = message;
                 
                 [HUD hideAnimated:YES afterDelay:2];
             }
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:2];
         }];
}

- (void)saveUserInfo:(OSCUserItem *)user
{
    [Config saveNewProfile:user];
    
    [OSCThread startPollingNotice];
    
    [self saveCookies];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
    _bakImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
}


#pragma mark - register
- (IBAction)registerAction:(UIButton *)sender {
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    _registerButton.backgroundColor = [UIColor clearColor];

}

#pragma mark - hidden Keyboard
- (void)hiddenKeyboardForTap         
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == _userNameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (sender == _passwordTextField) {
        [self hiddenKeyboardForTap];
        if (_loginButton.enabled) {
            [self loginAction:_loginButton];
        }
    }
}

#pragma mark - third login
CGRect oldFrame;
- (IBAction)thirdLoginAction:(UIButton *)sender {
    if (!isUpThirdLoginView) {
        isUpThirdLoginView = YES;
        if (!_alphaView.superview) {
            UIView* alphaView = [[UIView alloc] initWithFrame:self.view.bounds];
            _alphaView = alphaView;
            [_alphaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenThirdLoginView)]];
            _alphaView.userInteractionEnabled = YES;
            [self.view insertSubview:_alphaView belowSubview:_thirdLoginView];
        }
        _alphaView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.01];
        self.thirdLoginView.transform = CGAffineTransformMakeTranslation(0, 0);
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _alphaView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.47];
                             
                             self.thirdLoginView.transform = CGAffineTransformMakeTranslation(0, -94);
                         } completion:^(BOOL finished) {
                             self.thirdLoginView.transform = CGAffineTransformMakeTranslation(0, 0);

                             _alphaView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.47];
                             CGRect frame = self.thirdLoginView.frame;
                             oldFrame = _thirdLoginView.frame;
                             frame.origin.y = oldFrame.origin.y - 94;
                             self.thirdLoginView.frame = frame;
                         }];
    } else {
        
        [self hiddenThirdLoginView];
    }
}

- (void)hiddenThirdLoginView
{
    isUpThirdLoginView = NO;
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.thirdLoginView.transform = CGAffineTransformMakeTranslation(0,94);
                         
                         _alphaView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.01];
                     } completion:^(BOOL finished) {
                         self.thirdLoginView.transform = CGAffineTransformMakeTranslation(0,0);
                         self.thirdLoginView.frame = oldFrame;
                         [_alphaView removeFromSuperview];
                     }];

}

#pragma mark - third login
- (IBAction)weiboLoginAction:(id)sender {
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHex:0xFD6D09]];
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://sns.whalecloud.com/sina2/callback";
    request.scope = @"all";
    
    [WeiboSDK sendRequest:request];
}

- (IBAction)weChatLoginAction:(id)sender {
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"osc_wechat_login" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (IBAction)QQLoginAction:(id)sender {
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100942993" andDelegate:self];
    [_tencentOAuth authorize:@[kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _userNameTextField) {
        [_passwordTextField resignFirstResponder];
        [Utils setButtonBorder:_userNameView isFail:NO isEditing:YES];
        [Utils setButtonBorder:_passWordView isFail:NO isEditing:NO];
    } else if (textField == _passwordTextField) {
        [_userNameTextField resignFirstResponder];
        [Utils setButtonBorder:_userNameView isFail:NO isEditing:NO];
        [Utils setButtonBorder:_passWordView isFail:NO isEditing:YES];
    }
    
    [self buttonStateEnable];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [Utils setButtonBorder:_userNameView isFail:NO isEditing:NO];
    [Utils setButtonBorder:_passWordView isFail:NO isEditing:NO];
    
    [self buttonStateEnable];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self buttonStateEnable];
    
    if (textField == _userNameTextField) {
        if (range.length == 0 && range.location == 0 && _passwordTextField.text.length >= 6) {
            _loginButton.backgroundColor = [UIColor navigationbarColor];
            [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _loginButton.enabled = YES;
        } else if (range.length == 1 && range.location == 0) {
            _loginButton.backgroundColor = [UIColor colorWithHex:0x43815c];
            [_loginButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
            _loginButton.enabled = NO;
        }
    } else if (textField == _passwordTextField) {
        if (range.length == 0 && range.location >= 5 && _userNameTextField.text.length > 0) {
            _loginButton.backgroundColor = [UIColor navigationbarColor];
            [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _loginButton.enabled = YES;
        } else if (range.length == 1 && range.location <= 5) {
            _loginButton.backgroundColor = [UIColor colorWithHex:0x43815c];
            [_loginButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
            _loginButton.enabled = NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    _loginButton.backgroundColor = [UIColor colorWithHex:0x43815c];
    [_loginButton setTitleColor:[UIColor colorWithHex:0xfffff alpha:0.2] forState:UIControlStateNormal];
    _loginButton.enabled = NO;
    
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
    
    if (notification.name == UIKeyboardWillShowNotification) {
        if (isShowKeyboard == NO) {
            [UIView animateWithDuration:timeInt
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 _oscLogView.alpha = 0;
                                 _registerButton.hidden = YES;
                                 
                                 _userNameView.frame = [self startAnimationForEditing:_userNameView];
                                 _passWordView.frame = [self startAnimationForEditing:_passWordView];
                                 _loginButton.frame = [self startAnimationForEditing:_loginButton];
                                 _forgetButton.frame = [self startAnimationForEditing:_forgetButton];
                                 
                                 _nameToTopHeight.constant = 175 - maxY;
                                 
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
                             _oscLogView.alpha = 1;
                             _oscLogView.hidden = CGRectGetHeight(self.view.frame) > 550 ? NO : YES;
                             _registerButton.hidden = NO;
                             
                             _userNameView.frame = [self stopAnimationForEditing:_userNameView];
                             _passWordView.frame = [self stopAnimationForEditing:_passWordView];
                             _loginButton.frame = [self stopAnimationForEditing:_loginButton];
                             _forgetButton.frame = [self stopAnimationForEditing:_forgetButton];
                             
                             _nameToTopHeight.constant = 175;
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

#pragma mark - QQ login
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSLog(@"登录失败");
}

- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && [_tencentOAuth.accessToken length]) {
        NSString *userInfo = [NSString stringWithFormat:@"{"
                              @"\"openid\": \"%@\", "
                              @"\"access_token\": \"%@\""
                              @"}",
                              _tencentOAuth.openId, _tencentOAuth.accessToken];
        
        [self loginWithCatalog:@"qq" andAccountInfo:userInfo];//第三方登录处理
    }
}

- (void)tencentDidNotNetWork
{
    NSLog(@"请检查网络");
}

#pragma mark - weiChat login

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode != 0) {return;}
        
        SendAuthResp *temp = (SendAuthResp *)resp;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token"]
          parameters:@{
                       @"appid": @"wxa8213dc827399101",
                       @"secret": @"5c716417ce72ff69d8cf0c43572c9284",
                       @"code": temp.code,
                       @"grant_type": @"authorization_code",
                       }
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 NSString *info = [NSString stringWithFormat:@"{"
                                   @"\"access_token\":\"%@\",\n"
                                   @"\"expires_in\":%@,\n"
                                   @"\"openid\":\"%@\",\n"
                                   @"\"refresh_token\":\"%@\",\n"
                                   @"\"scope\":\"%@\",\n"
                                   @"\"unionid\":\"%@\""
                                   @"}",
                                   responseObject[@"access_token"],
                                   responseObject[@"expires_in"],
                                   responseObject[@"openid"],
                                   responseObject[@"refresh_token"],
                                   responseObject[@"scope"],
                                   responseObject[@"unionid"]];
                 
                 [self loginWithCatalog:@"wechat" andAccountInfo:info];//第三方登录处理
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"error: %@", error);
             }];
    }
}

#pragma mark - weibo login

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self hiddenThirdLoginView];
    
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        
        if (!authResponse.userID) {return;}
        NSString *info = [NSString stringWithFormat:@"{"
                          @"\"openid\": %@,\n"
                          @"\"access_token\": \"%@\",\n"
                          @"\"refresh_token\": \"%@\",\n"
                          @"\"expires_in\": \"%@\""
                          @"}",
                          authResponse.userID,
                          authResponse.accessToken,
                          authResponse.refreshToken,
                          authResponse.expirationDate];
        [self loginWithCatalog:@"weibo" andAccountInfo:info];//第三方登录处理
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

#pragma mark 处理第三方账号

- (void)loginWithCatalog:(NSString *)catalog andAccountInfo:(NSString *)info
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_ACCOUNT_OPEN_LOGIN]
      parameters:@{
                   @"catalog" : catalog,
                   @"info"    : info,
                   @"appToken": Application_AppToken
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 NSDictionary *result = responseObject[@"result"];
                 OSCUserItem *user = [OSCUserItem mj_objectWithKeyValues:result];
                 
                 [self saveUserInfo:user];
             } else {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = responseObject[@"message"];
                 
                 [HUD hideAnimated:YES afterDelay:2];
             }
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:2];
         }];
}

@end
