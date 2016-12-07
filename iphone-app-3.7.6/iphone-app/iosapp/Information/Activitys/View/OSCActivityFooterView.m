//
//  OSCActivityFooterView.m
//  iosapp
//
//  Created by 王恒 on 16/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityFooterView.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCActivityFooterView ()<IMYWebViewDelegate>

@property (nonatomic,strong) IMYWebView *contentView;

@end

@implementation OSCActivityFooterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _contentView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 0) usingUIWebView:NO];
    _contentView.userInteractionEnabled = YES;
    [_contentView.scrollView setBounces:NO];
    [_contentView.scrollView setScrollEnabled:NO];
    _contentView.delegate = self;
    [self addSubview:_contentView];
}

- (void)setNeedLoad:(NSString *)needLoad{
    _needLoad = needLoad;
    if (needLoad.length > 0 ) {
        [_contentView loadHTMLString:needLoad baseURL:[NSBundle mainBundle].resourceURL];
    }
}

#pragma --mark IMYWebViewDelegate
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL shouldStart;
    if ([self.delegate respondsToSelector:@selector(contentView:shouldStart:)]) {
        shouldStart = [self.delegate contentView:webView shouldStart:request];
    }
    return shouldStart;
}

- (void)webViewDidFinishLoad:(IMYWebView *)webView{
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(NSNumber* result, NSError *err) {
        CGFloat webViewHeight = [result floatValue];
        webView.frame = CGRectMake(0, 0, kScreenSize.width, webViewHeight);
        if ([self.delegate respondsToSelector:@selector(contentViewDidFinishLoadWithHederViewHeight:)]) {
            [self.delegate contentViewDidFinishLoadWithHederViewHeight:webViewHeight];
        }
    }];
}

@end
