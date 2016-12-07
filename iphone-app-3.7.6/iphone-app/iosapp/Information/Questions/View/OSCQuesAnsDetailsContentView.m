//
//  OSCQuesAnsDetailsContentView.m
//  iosapp
//
//  Created by Graphic-one on 16/11/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCQuesAnsDetailsContentView.h"
#import "OSCQuestion.h"
#import "IMYWebView.h"
#import "Utils.h"

#import <YYKit.h>
#import <Masonry.h>

#define padding_top 12
#define padding_bottom padding_top
#define padding_left 16
#define padding_right padding_left
#define kScreen [UIScreen mainScreen].bounds.size.width
#define titleLb_space_tagLb 8
#define tagLb_space_webView 4
#define webView_space_authorAndTimeLb 2
#define iconImageView_Width 15
#define iconImageView_Height 10
#define countLb_Height 15
#define countLb_space_iconImageView 5
#define viewCountLb_space_commentLb 12

@interface OSCQuesAnsDetailsContentView () <IMYWebViewDelegate>
{
    __weak YYLabel* _titleLb;
    __weak YYLabel* _tagLb;
    
    __weak IMYWebView* _webView;
    __weak YYLabel* _authorAndTimeLb;
    __weak UIImageView* _viewCountImageView;
    __weak YYLabel* _viewCountLb;
    __weak UIImageView* _commentCountImageView;
    __weak YYLabel* _commentCountLb;
}
@property (nonatomic,assign) CGFloat fullWidth;

@end

@implementation OSCQuesAnsDetailsContentView
{
    CGFloat _titleLB_Height , _tagLb_Height , _webView_Height;
    CGFloat _authorAndTimeLb_width , _viewCountLb_width , _commentCountLb_width;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self settingUI];
        
    }
    return self;
}

#pragma mark - settingUI
- (void)settingUI
{
    _fullWidth = kScreen - padding_left - padding_right;

    [self addSubview:({
        YYLabel* titleLb = [YYLabel new];
        titleLb.font = [UIFont systemFontOfSize:22];
        titleLb.numberOfLines = 0;
        _titleLb = titleLb;
        _titleLb;
    })];
    [self addSubview:({
        YYLabel* tagLb = [YYLabel new];
        tagLb.font = [UIFont systemFontOfSize:10];
        tagLb.numberOfLines = 0;
        _tagLb = tagLb;
        _tagLb;
    })];
    
    
    [self addSubview:({
        IMYWebView* webView = [[IMYWebView alloc] initWithFrame:(CGRectMake(0, 0, _fullWidth, 10)) usingUIWebView:NO];
        webView.delegate = self;
        webView.userInteractionEnabled = YES;
        [webView.scrollView setBounces:NO];
        [webView.scrollView setScrollEnabled:NO];
        _webView = webView;
    })];
    
    
    [self addSubview:({
        YYLabel* authorAndTimeLb = [YYLabel new];
        authorAndTimeLb.font = [UIFont systemFontOfSize:12];
        authorAndTimeLb.numberOfLines = 1;
        authorAndTimeLb.textColor = [UIColor colorWithHex:0x9D9D9D];
        _authorAndTimeLb = authorAndTimeLb;
        _authorAndTimeLb;
    })];
    
    [self addSubview:({
        UIImageView* viewCountImageView = [UIImageView new];
        viewCountImageView.image = [UIImage imageNamed:@"ic_view"];
        viewCountImageView.contentMode = UIViewContentModeScaleToFill;
        _viewCountImageView = viewCountImageView;
    })];
    [self addSubview:({
        YYLabel* viewCountLb = [YYLabel new];
        viewCountLb.font = [UIFont systemFontOfSize:12];
        viewCountLb.textColor = [UIColor colorWithHex:0x9D9D9D];
        viewCountLb.numberOfLines = 1;
        _viewCountLb = viewCountLb;
        _viewCountLb;
    })];
    [self addSubview:({
        UIImageView* commentCountImageView = [UIImageView new];
        commentCountImageView.image = [UIImage imageNamed:@"ic_comment"];
        commentCountImageView.contentMode = UIViewContentModeScaleToFill;
        _commentCountImageView = commentCountImageView;
    })];
    [self addSubview:({
        YYLabel* commentCountLb = [YYLabel new];
        commentCountLb.font = [UIFont systemFontOfSize:12];
        commentCountLb.numberOfLines = 1;
        commentCountLb.textColor = [UIColor colorWithHex:0x9D9D9D];
        _commentCountLb = commentCountLb;
        _commentCountLb;
    })];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLb.frame = (CGRect){{padding_left,padding_top},{_fullWidth,_titleLB_Height}};
    _tagLb.frame = (CGRect){{padding_left,CGRectGetMaxY(_titleLb.frame) + titleLb_space_tagLb},{_fullWidth,_tagLb_Height}};
    _webView.frame = (CGRect){{padding_left,CGRectGetMaxY(_tagLb.frame) + tagLb_space_webView},{_fullWidth,_webView_Height}};
    _authorAndTimeLb.frame = (CGRect){{padding_left,CGRectGetMaxY(_webView.frame) + webView_space_authorAndTimeLb},{_authorAndTimeLb_width,15}};
    
    _commentCountLb.frame = (CGRect){{kScreen - padding_right - _commentCountLb_width,CGRectGetMinY(_authorAndTimeLb.frame)},{_commentCountLb_width,countLb_Height}};
    _commentCountImageView.frame = (CGRect){{CGRectGetMinX(_commentCountLb.frame) - countLb_space_iconImageView - iconImageView_Width,CGRectGetMinY(_authorAndTimeLb.frame) + 2},{iconImageView_Width,iconImageView_Height}};
    _viewCountLb.frame = (CGRect){{CGRectGetMinX(_commentCountImageView.frame) - viewCountLb_space_commentLb - _viewCountLb_width,CGRectGetMinY(_authorAndTimeLb.frame)},{_viewCountLb_width,countLb_Height}};
    _viewCountImageView.frame = (CGRect){{CGRectGetMinX(_viewCountLb.frame) - countLb_space_iconImageView - iconImageView_Width,CGRectGetMinY(_authorAndTimeLb.frame) + 2},{iconImageView_Width,iconImageView_Height}};
    _authorAndTimeLb_width = CGRectGetMinX(_viewCountImageView.frame) - padding_left;
}

- (void)setQuestion:(OSCQuestion *)question{
    _titleLb.text = question.title;
    _titleLB_Height = [[self class] getHeightWithString:question.title WithFont:[UIFont systemFontOfSize:22]];
    _tagLb.attributedText = [self setTagAttributedString:question.tags];
    
    _authorAndTimeLb.text = [NSString stringWithFormat:@"%@ %@", question.author, [[NSDate dateFromString:question.pubDate] timeAgoSinceNow]];

    _viewCountLb.text = [NSString stringWithFormat:@"%ld", (long)question.viewCount];
    _viewCountLb_width = [_viewCountLb.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}].width;
    _commentCountLb.text = [NSString stringWithFormat:@"%ld", (long)question.commentCount];
    _commentCountLb_width = [_commentCountLb.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}].width;
    
    [_webView loadHTMLString:question.body baseURL:[NSBundle mainBundle].resourceURL];
}

- (NSAttributedString *)setTagAttributedString:(NSArray *)array
{
    if (!array || array.count < 1) {
        _tagLb_Height = - tagLb_space_webView;
        return nil;
    }
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    __block NSUInteger stringLength = 0;
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", obj]]];
        
        [attributedString addAttributes:@{
                                          NSBackgroundColorAttributeName : [UIColor colorWithHex:0xf6f6f6],
                                          NSForegroundColorAttributeName : [UIColor newAssistTextColor],
                                          NSFontAttributeName            : [UIFont systemFontOfSize:12],
                                          }
                                  range:NSMakeRange(stringLength, obj.length+2)];
        
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        stringLength += obj.length + 3;
    }];
    
    _tagLb_Height = [attributedString boundingRectWithSize:(CGSize){kScreen - padding_left - padding_right,MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
    
    return attributedString;
}

+ (CGFloat)getHeightWithString:(NSString *)string WithFont:(UIFont *)font{
    return [string boundingRectWithSize:CGSizeMake(kScreen - padding_left - padding_right, MAXFLOAT)
                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                             attributes:@{NSFontAttributeName:font} context:nil].size.height;
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
    [webView evaluateJavaScript:@"document.documentElement.scrollHeight" completionHandler:^(NSNumber* result, NSError *err) {
        _webView_Height = ceil([result integerValue]);
        [self layoutSubviews];
        if ([self.delegate respondsToSelector:@selector(contentViewDidFinishLoadWithHederViewHeight:)]) {
            [self.delegate contentViewDidFinishLoadWithHederViewHeight:CGRectGetMaxY(_authorAndTimeLb.frame) + padding_bottom];
        }
    }];
}

@end
