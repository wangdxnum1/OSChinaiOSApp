//
//  UIView+Common.m
//  iosapp
//
//  Created by Graphic-one on 16/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UIView+Common.h"
#import "Utils.h"

#import <objc/runtime.h>
#import <Masonry.h>

@interface UIView ()

@property (nonatomic,copy) void(^reloadAction)();

@end

@implementation UIView (Common)
- (void)setReloadAction:(void (^)())reloadAction{
    objc_setAssociatedObject(self, @selector(reloadAction), reloadAction, OBJC_ASSOCIATION_COPY);
}
- (void (^)())reloadAction{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)hideAllGeneralPage{
    if (!self.loadingView.superview) { [self.loadingView removeFromSuperview]; }
    if (!self.errorPageView.superview) { [self.errorPageView removeFromSuperview]; }
    if (!self.blankPageView.superview) { [self.blankPageView removeFromSuperview]; }
    if (!self.loginPageView.superview) { [self.loginPageView removeFromSuperview]; }
    if (!self.customPageView.superview) { [self.customPageView removeFromSuperview]; }
}


//OSCLoadingPageView
- (void)setLoadingView:(OSCLoadingPageView *)loadingView{
    [self willChangeValueForKey:NSStringFromSelector(@selector(loadingView))];
    objc_setAssociatedObject(self, @selector(loadingView), loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(loadingView))];
}
- (OSCLoadingPageView *)loadingView{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)beginLoading{
    if (!self.errorPageView.superview) { [self.errorPageView removeFromSuperview]; }
    if (!self.blankPageView.superview) { [self.blankPageView removeFromSuperview]; }
    if (!self.loginPageView.superview) { [self.loginPageView removeFromSuperview]; }
    if (!self.customPageView.superview) { [self.customPageView removeFromSuperview]; }
    
    if (!self.loadingView) {
        self.loadingView = [[OSCLoadingPageView alloc]initWithFrame:self.bounds];
    }
    [self addSubview:self.loadingView];
    [self bringSubviewToFront:self.loadingView];
    
    [self.loadingView startAnimation];
}
- (void)endLoading{
    if (self.loadingView) {
        [self.loadingView stopAnimation];
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}



//OSCErrorPageView
- (void)setErrorPageView:(OSCErrorPageView *)errorPageView{
    [self willChangeValueForKey:NSStringFromSelector(@selector(errorPageView))];
    objc_setAssociatedObject(self, @selector(errorPageView), errorPageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(errorPageView))];
}
- (OSCErrorPageView *)errorPageView{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)configReloadAction:(void (^)())block{
    self.reloadAction = block;
    if (self.errorPageView && self.reloadAction) {
        self.errorPageView.didClickReloadBlock = self.reloadAction;
    }
}
- (void)showErrorPageView{
    if (!self.loadingView.superview) { [self.loadingView removeFromSuperview]; }
    if (!self.blankPageView.superview) { [self.blankPageView removeFromSuperview]; }
    if (!self.loginPageView.superview) { [self.loginPageView removeFromSuperview]; }
    if (!self.customPageView.superview) { [self.customPageView removeFromSuperview]; }
    
    if (!self.errorPageView) {
        self.errorPageView = [[OSCErrorPageView alloc]initWithFrame:self.bounds];
        if (self.reloadAction) {
            self.errorPageView.didClickReloadBlock = self.reloadAction;
        }
    }
    [self addSubview:self.errorPageView];
    [self bringSubviewToFront:self.errorPageView];
}
- (void)hideErrorPageView{
    if (self.errorPageView) {
        //        self.errorPageView.didClickReloadBlock = nil;
        //        self.reloadAction = nil;
        [self.errorPageView removeFromSuperview];
        self.errorPageView = nil;
    }
}



//OSCBlankPageView
- (void)setBlankPageView:(OSCBlankPageView *)blankPageView{
    [self willChangeValueForKey:NSStringFromSelector(@selector(blankPageView))];
    objc_setAssociatedObject(self, @selector(blankPageView), blankPageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(blankPageView))];
}
- (OSCBlankPageView *)blankPageView{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)showBlankPageView{
    if (!self.loadingView.superview) { [self.loadingView removeFromSuperview]; }
    if (!self.errorPageView.superview) { [self.errorPageView removeFromSuperview]; }
    if (!self.loginPageView.superview) { [self.loginPageView removeFromSuperview]; }
    if (!self.customPageView.superview) { [self.customPageView removeFromSuperview]; }
    
    if (!self.blankPageView) {
        self.blankPageView = [[OSCBlankPageView alloc]initWithFrame:self.bounds];
    }
    [self addSubview:self.blankPageView];
    [self bringSubviewToFront:self.blankPageView];
}
- (void)hideBlankPageView{
    if (self.blankPageView) {
        [self.blankPageView removeFromSuperview];
        self.blankPageView = nil;
    }
}



//OSCLogInPageView
-(void)setLoginPageView:(OSCLogInPageView *)loginPageView{
    [self willChangeValueForKey:NSStringFromSelector(@selector(loginPageView))];
    objc_setAssociatedObject(self, @selector(loginPageView), loginPageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(loginPageView))];
}
- (OSCLogInPageView *)loginPageView{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)showLoginPageView{
    if (!self.loadingView.superview) { [self.loadingView removeFromSuperview]; }
    if (!self.errorPageView.superview) { [self.errorPageView removeFromSuperview]; }
    if (!self.blankPageView.superview) { [self.blankPageView removeFromSuperview]; }
    if (!self.customPageView.superview) { [self.customPageView removeFromSuperview]; }
    
    if (!self.loginPageView) {
        self.loginPageView = [[OSCLogInPageView alloc]initWithFrame:self.bounds];
    }
    [self addSubview:self.loginPageView];
    [self bringSubviewToFront:self.loginPageView];
}
- (void)hideloginPageView{
    if (self.loginPageView) {
        [self.loginPageView removeFromSuperview];
        self.loginPageView = nil;
    }
}



//OSCCustomPageView
- (void)setCustomPageView:(OSCCustomPageView *)customPageView{
    [self willChangeValueForKey:NSStringFromSelector(@selector(customPageView))];
    objc_setAssociatedObject(self, @selector(customPageView), customPageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:NSStringFromSelector(@selector(customPageView))];
}
- (OSCCustomPageView *)customPageView{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)showCustomPageViewWithImage:(UIImage *)image tipString:(NSString *)tip{
    if (!self.loadingView.superview) { [self.loadingView removeFromSuperview]; }
    if (!self.errorPageView.superview) { [self.errorPageView removeFromSuperview]; }
    if (!self.blankPageView.superview) { [self.blankPageView removeFromSuperview]; }
    if (!self.loginPageView.superview) { [self.loginPageView removeFromSuperview]; }
    
    if (!self.customPageView) {
        self.customPageView = [[OSCCustomPageView alloc]initWithImage:image tip:tip];
        self.customPageView.backgroundColor = [UIColor whiteColor];
        self.customPageView.frame = self.bounds;
    }
    [self addSubview:self.customPageView];
    [self bringSubviewToFront:self.customPageView];
}
- (void)hideCustomPageView{
    if (self.customPageView) {
        [self.customPageView removeFromSuperview];
        self.customPageView = nil;
    }
}

@end






#pragma mark --- OSCLoadingPageView

@interface OSCLoadingPageView ()
@property (nonatomic,weak) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic,weak) UILabel* loadingTipLabel;

@property (nonatomic,assign,readwrite) BOOL isLoading ;
@end

@implementation OSCLoadingPageView

#pragma mark - init Method
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isLoading = NO;
        
        UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView = activityIndicatorView;
        [self addSubview:_activityIndicatorView];
        
        UILabel* loadingTipLabel = [[UILabel alloc]init];
        loadingTipLabel.numberOfLines = 1;
        loadingTipLabel.font = [UIFont systemFontOfSize:15];
        loadingTipLabel.textAlignment = NSTextAlignmentCenter;
        loadingTipLabel.textColor = [UIColor grayColor];
        loadingTipLabel.text = @"正在加载...";
        _loadingTipLabel = loadingTipLabel;
        [self addSubview:_loadingTipLabel];
        
        [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.height.equalTo(@25);
            make.bottom.equalTo(self.mas_centerY).offset(-5);
        }];
        [_loadingTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@50);
            make.top.equalTo(self.mas_centerY).offset(5);
        }];
        [self setHidden:NO];
    }
    return self;
}


#pragma mark - public Method
- (void)startAnimation{
    self.hidden = NO;
    [_activityIndicatorView startAnimating];
    _isLoading = YES;
}
- (void)stopAnimation{
    self.hidden = YES;
    [_activityIndicatorView stopAnimating];
    _isLoading = NO;
}


@end


#pragma mark --- OSCErrorPageView

@interface OSCErrorPageView ()
@property (nonatomic,weak) UIImageView* errorImageView;
@property (nonatomic,weak) UILabel* errorTipLabel;
@property (nonatomic,weak) UIButton* reloadButton;
@end

@implementation OSCErrorPageView
#pragma mark - init Method
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* errorImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_tip_fail"]];
        _errorImageView = errorImageView;
        [self addSubview:_errorImageView];
        
        UILabel* errorTipLabel = [[UILabel alloc]init];
        errorTipLabel.numberOfLines = 1;
        errorTipLabel.font = [UIFont systemFontOfSize:15];
        errorTipLabel.textAlignment = NSTextAlignmentCenter;
        errorTipLabel.textColor = [UIColor grayColor];
        errorTipLabel.text = @"很抱歉,网络似乎出了点状况...";
        _errorTipLabel = errorTipLabel;
        [self addSubview:_errorTipLabel];
        
        UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        reloadButton.layer.masksToBounds = YES;
        reloadButton.layer.cornerRadius = 15;
        reloadButton.layer.borderColor = [UIColor grayColor].CGColor;
        reloadButton.layer.borderWidth = 1.0f;
        [reloadButton setBackgroundImage:[Utils createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [reloadButton setBackgroundImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
        [reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
        [reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [reloadButton addTarget:self action:@selector(_clickReloadButton:) forControlEvents:UIControlEventTouchUpInside];
        _reloadButton = reloadButton;
        [self addSubview:_reloadButton];
        
        
        [_errorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@140);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).offset(-80);
        }];
        
        [_errorTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@50);
            make.top.equalTo(_errorImageView.mas_bottom).offset(5);
        }];
        
        [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@40);
            make.centerX.equalTo(self);
            make.top.equalTo(_errorTipLabel.mas_bottom).offset(10);
        }];
    }
    return self;
}

#pragma mark - public Method
- (void)_clickReloadButton:(UIButton* )btn{
    if (_didClickReloadBlock) {
        _didClickReloadBlock();
    }
}

@end



#pragma mark --- OSCBlankPageView
@interface OSCBlankPageView ()
@property (nonatomic,weak) UIImageView* nodataImageView;
@property (nonatomic,weak) UILabel* nodataTipLabel;
@end

@implementation OSCBlankPageView
#pragma mark - init Method
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* nodataImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_tip_smile"]];
        _nodataImageView = nodataImageView;
        [self addSubview:_nodataImageView];
        
        UILabel* nodataTipLabel = [[UILabel alloc]init];
        nodataTipLabel.numberOfLines = 1;
        nodataTipLabel.font = [UIFont systemFontOfSize:15];
        nodataTipLabel.textAlignment = NSTextAlignmentCenter;
        nodataTipLabel.textColor = [UIColor grayColor];
        nodataTipLabel.text = @"这里没有数据呢,赶紧弄出点动静吧~";
        _nodataTipLabel = nodataTipLabel;
        [self addSubview:_nodataTipLabel];
        
        [_nodataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@140);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).offset(-30);
        }];
        
        [_nodataTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@50);
            make.top.equalTo(_nodataImageView.mas_bottom).offset(5);
        }];
    }
    return self;
}

#pragma mark - public Method

@end



#pragma mark --- OSCLogInPageView
@interface OSCLogInPageView ()
@property (nonatomic,weak) UIImageView* loginImageView;
@property (nonatomic,weak) UILabel* loginTipLabel;
@property (nonatomic,weak) UIButton* loginButton;
@end

@implementation OSCLogInPageView
#pragma mark - init Method
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* loginImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_tip_fail"]];
        _loginImageView = loginImageView;
        [self addSubview:_loginImageView];
        
        UILabel* loginTipLabel = [[UILabel alloc]init];
        loginTipLabel.numberOfLines = 1;
        loginTipLabel.font = [UIFont systemFontOfSize:15];
        loginTipLabel.textAlignment = NSTextAlignmentCenter;
        loginTipLabel.textColor = [UIColor grayColor];
        loginTipLabel.text = @"亲,您还没登录呢~";
        _loginTipLabel = loginTipLabel;
        [self addSubview:_loginTipLabel];
        
        UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.layer.masksToBounds = YES;
        loginButton.layer.cornerRadius = 15;
        loginButton.layer.borderColor = [UIColor grayColor].CGColor;
        loginButton.layer.borderWidth = 1.0f;
        [loginButton setBackgroundImage:[Utils createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [loginButton setBackgroundImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.3]] forState:UIControlStateHighlighted];
        [loginButton setTitle:@"马上登录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(gotoLogIn) forControlEvents:UIControlEventTouchUpInside];
        _loginButton = loginButton;
        [self addSubview:_loginButton];
        
        
        [_loginImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@140);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).offset(-80);
        }];
        
        [_loginTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@50);
            make.top.equalTo(_loginImageView.mas_bottom).offset(5);
        }];
        
        [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@40);
            make.centerX.equalTo(self);
            make.top.equalTo(_loginTipLabel.mas_bottom).offset(10);
        }];
    }
    return self;
}

#pragma mark --- Go to login
- (void)gotoLogIn{
    if (_didClickLogInBlock) {
        _didClickLogInBlock();
    }
}

@end



#pragma mark --- OSCCustomPageView
@interface OSCCustomPageView ()
@property (nonatomic,strong) UIImageView* customImageView;
@property (nonatomic,strong) UILabel* tipLabel;
@end

@implementation OSCCustomPageView
- (instancetype)initWithImage:(UIImage *)image tip:(NSString *)tip{
    self = [super init];
    if (self) {
        UIImageView* customImageView = [UIImageView new];
        customImageView.image = image;
        _customImageView = customImageView;
        [self addSubview:_customImageView];
        
        UILabel* tipLabel = [[UILabel alloc]init];
        tipLabel.numberOfLines = 1;
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.text = tip;
        _tipLabel = tipLabel;
        [self addSubview:_tipLabel];
        
        [_customImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@140);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).offset(-30);
        }];
        
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.equalTo(@50);
            make.top.equalTo(_customImageView.mas_bottom).offset(5);
        }];
    }
    return self;
}



@end
