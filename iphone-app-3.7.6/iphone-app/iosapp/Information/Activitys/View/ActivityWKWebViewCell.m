//
//  ActivityWKWebViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/10/20.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityWKWebViewCell.h"
#import <WebKit/WebKit.h>

#import <Masonry.h>

#define screen_padding 10

@interface ActivityWKWebViewCell () <WKUIDelegate,WKNavigationDelegate>
@property (nonatomic , weak) WKWebView* webView;
@property (nonatomic , weak) WKUserContentController* userContentController;
@end

@implementation ActivityWKWebViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews{
    [self.contentView addSubview:({
        WKUserContentController* userContentController = [[WKUserContentController alloc]init];
        _userContentController = userContentController;
        
        WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc]init];
        configuration.userContentController = _userContentController;
        
        WKWebView* webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:configuration];
        webView.scrollView.bounces = NO;
        webView.scrollView.scrollEnabled = NO;
        webView.opaque = NO;
        webView.backgroundColor = [UIColor clearColor];
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        _webView = webView;
        _webView;
    })];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).offset(10);
    }];
}


#pragma mark  setting M
- (void)setHTML_String:(NSString *)HTML_String{
    _HTML_String = HTML_String;
    
    [_webView loadHTMLString:HTML_String baseURL:[NSBundle mainBundle].resourceURL];
}


#pragma mark  WKNavigation Delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.body.offsetHeight"
              completionHandler:^(NSNumber* webViewHeight, NSError * _Nullable error)
    {
        if ([_delegate respondsToSelector:@selector(ActivityWKWebViewCellDidFinshLoadHTML:webView:navigation:webViewHeight:)]) {
            [_delegate ActivityWKWebViewCellDidFinshLoadHTML:self webView:webView navigation:navigation webViewHeight:[webViewHeight floatValue]];
        }
    }];
}

@end







