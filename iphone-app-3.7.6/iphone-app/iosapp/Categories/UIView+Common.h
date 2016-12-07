//
//  UIView+Common.h
//  iosapp
//
//  Created by Graphic-one on 16/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCLoadingPageView , OSCErrorPageView , OSCBlankPageView , OSCLogInPageView , OSCCustomPageView;
@interface UIView (Common)

/** Placeholder */
- (void)hideAllGeneralPage;

//OSCLoadingPageView
@property (nonatomic,strong) OSCLoadingPageView* loadingView;
- (void)beginLoading;
- (void)endLoading;

//OSCErrorPageView
@property (nonatomic,strong) OSCErrorPageView* errorPageView;
- (void)configReloadAction:(void(^)())block;
- (void)showErrorPageView;
- (void)hideErrorPageView;

//OSCBlankPageView
@property (nonatomic,strong) OSCBlankPageView* blankPageView;
- (void)showBlankPageView;
- (void)hideBlankPageView;

//OSCLogInPageView
@property (nonatomic,strong) OSCLogInPageView* loginPageView;
- (void)showLoginPageView;
- (void)hideloginPageView;

//OSCCustomPageView
@property (nonatomic,strong) OSCCustomPageView* customPageView;
- (void)showCustomPageViewWithImage:(UIImage* )image
                          tipString:(NSString* )tip;
- (void)hideCustomPageView;


@end





/** Placeholder */
#pragma mark --- OSCLoadingPageView
@interface OSCLoadingPageView : UIView
@property (nonatomic,assign,readonly) BOOL isLoading ;
- (void)startAnimation;
- (void)stopAnimation;
@end

#pragma mark --- OSCErrorPageView
@interface OSCErrorPageView : UIView
@property (nonatomic,copy) void(^didClickReloadBlock)();
@end

#pragma mark --- OSCBlankPageView
@interface OSCBlankPageView : UIView  @end

#pragma mark --- OSCLogInPageView
@interface OSCLogInPageView : UIView
@property (nonatomic,copy) void(^didClickLogInBlock)();
@end;

#pragma mark --- OSCCustomPageView
@interface OSCCustomPageView : UIView
- (instancetype)initWithImage:(UIImage* )image
                          tip:(NSString* )tip;
@end




