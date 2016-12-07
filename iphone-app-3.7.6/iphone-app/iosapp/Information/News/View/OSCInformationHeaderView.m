//
//  OSCInformationHeaderView.m
//  iosapp
//
//  Created by 王恒 on 16/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformationHeaderView.h"
#import <Masonry/Masonry.h>
#import "UIColor+Util.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCInformationHeaderView () <IMYWebViewDelegate>

@property (nonatomic,strong) OSCInformationTitleView *titleView;
@property (nonatomic,strong) IMYWebView *contentView;

@end

@implementation OSCInformationHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _titleView = [[OSCInformationTitleView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self addSubview:_titleView];
    
    _contentView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width - 32, 0) usingUIWebView:NO];
    _contentView.userInteractionEnabled = YES;
    [_contentView.scrollView setBounces:NO];
    [_contentView.scrollView setScrollEnabled:NO];
    _contentView.delegate = self;
    [self addSubview:_contentView];
}

- (void)setNewsModel:(OSCInformationDetails *)newsModel{
    _newsModel = newsModel;
    _titleView.newsModel = newsModel;
    if (newsModel.body.length > 0 ) {
        [_contentView loadHTMLString:newsModel.body baseURL:[NSBundle mainBundle].resourceURL];
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
        webView.frame = CGRectMake(16, CGRectGetHeight(_titleView.frame), kScreenSize.width - 32, webViewHeight);
        if ([self.delegate respondsToSelector:@selector(contentViewDidFinishLoadWithHederViewHeight:)]) {
            [self.delegate contentViewDidFinishLoadWithHederViewHeight:CGRectGetHeight(_titleView.frame) + webViewHeight];
        }
    }];
}

@end




@interface OSCInformationTitleView ()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *peopleLabel;
@property (nonatomic,strong) UILabel *timeLabel;

@end

@implementation OSCInformationTitleView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:22.0];
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(16);
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
    }];
    
    _peopleLabel = [[UILabel alloc] init];
    _peopleLabel.font = [UIFont systemFontOfSize:12.0];
    _peopleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    [self addSubview:_peopleLabel];
    [_peopleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
        make.left.equalTo(self).offset(16);
        make.height.equalTo(@(14));
    }];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    _timeLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    [self addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
        make.left.equalTo(_peopleLabel.mas_right);
        make.height.equalTo(@(14));
    }];
}

- (void)setNewsModel:(OSCInformationDetails *)newsModel{
    _newsModel = newsModel;
    _titleLabel.text = newsModel.title;
    _peopleLabel.text = [NSString stringWithFormat:@"@%@  ", newsModel.author];
    _timeLabel.text = [self timeComponentsSep:newsModel.pubDate];
    self.frame = CGRectMake(0, 0, kScreenSize.width, [[self class] getHeightWithString:newsModel.title WithFont:[UIFont systemFontOfSize:22.0]]);
}

- (NSString *)timeComponentsSep:(NSString *)pubdate
{
    NSString *string = [pubdate componentsSeparatedByString:@" "][0];
    
    string = [string stringByReplacingCharactersInRange:NSMakeRange(7, 1) withString:@"月"];
    string = [string stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"年"];
    
    return [NSString stringWithFormat:@"发布于 %@日", string];
}

+ (float)getHeightWithString:(NSString *)string WithFont:(UIFont *)font{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(kScreenSize.width - 32, MAX_CANON) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.height + 16 + 11 + 16 + 8;
}

@end
