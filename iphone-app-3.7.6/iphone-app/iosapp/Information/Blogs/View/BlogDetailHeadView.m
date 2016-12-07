//
//  BlogDetailHeadView.m
//  iosapp
//
//  Created by 李萍 on 2016/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "BlogDetailHeadView.h"
#import "Utils.h"
#import "IMYWebView.h"
#import <Masonry.h>

#define padding_top 10
#define padding_bottom padding_top
#define padding_left 16
#define padding_right padding_left

#define bg_View_Height 60
#define portrait_size 36
#define portraitImageView_space_nameLb 8
#define portraitImageView_space_timeLb 8
#define countImageView_space_countLb 4
#define nameLb_SPACE_timeLb 2
#define titleLb_SPACE_CountBar 15
#define iconLb_height 18
#define count_space_count 12

#define button_width 50
#define button_height 25

#define icon_width 13
#define icon_height 10
#define kScreen_bound_width [UIScreen mainScreen].bounds.size.width

@interface BlogDetailHeadView ()

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIView *userInfoBottomLine;

@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *viewCountIcon;
@property (nonatomic, strong) UILabel *viewCountLabel;
@property (nonatomic, strong) UIImageView *commentIcon;
@property (nonatomic, strong) UILabel *commentCountLabel;
@property (nonatomic, strong) UIView *titleBottomLine;

@property (nonatomic, strong) UILabel *abstractLabel;
@property (nonatomic, strong) UIView *abstractBottomLine;

@end

@implementation BlogDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutSubView];
    }
    return self;
}

- (void)layoutSubView
{
    _bottomView = [UIView new];
    _bottomView.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self addSubview:_bottomView];
    
    _portraitView = [UIImageView new];
    [_portraitView setCornerRadius:portrait_size * 0.5 ];
    _portraitView.userInteractionEnabled = YES;
    _portraitView.contentMode = UIViewContentModeScaleAspectFit;
    [_bottomView addSubview:_portraitView];
    
    _userNameLabel = [UILabel new];
    _userNameLabel.font = [UIFont systemFontOfSize:14];
    _userNameLabel.textColor = [UIColor blackColor];
    [_bottomView addSubview:_userNameLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor newAssistTextColor];
    [_bottomView addSubview:_timeLabel];
    
    _relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_relationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_relationButton setBackgroundColor:[UIColor newSectionButtonSelectedColor]];
    [_relationButton setTitle:@"关注" forState:UIControlStateNormal];
    _relationButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_bottomView addSubview:_relationButton];
    _relationButton.layer.cornerRadius = 2;
    
    _userInfoBottomLine = [UIView new];
    _userInfoBottomLine.backgroundColor = [UIColor colorWithHex:0xC8C7CC];
    [self addSubview:_userInfoBottomLine];
    
    _iconLabel = [UILabel new];
    [self addSubview:_iconLabel];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:22];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_titleLabel];
    
    _viewCountIcon = [UIImageView new];
    _viewCountIcon.contentMode = UIViewContentModeScaleAspectFit;
    _viewCountIcon.image = [UIImage imageNamed:@"ic_view"];
    [self addSubview:_viewCountIcon];
    
    _viewCountLabel = [UILabel new];
    _viewCountLabel.font = [UIFont systemFontOfSize:12];
    _viewCountLabel.textColor = [UIColor newAssistTextColor];
    [self addSubview:_viewCountLabel];
    
    _commentIcon = [UIImageView new];
    _commentIcon.contentMode = UIViewContentModeScaleAspectFit;
    _commentIcon.image = [UIImage imageNamed:@"ic_comment"];
    [self addSubview:_commentIcon];
    
    _commentCountLabel = [UILabel new];
    _commentCountLabel.font = [UIFont systemFontOfSize:12];
    _commentCountLabel.textColor = [UIColor newAssistTextColor];
    [self addSubview:_commentCountLabel];
    
    _titleBottomLine = [UIView new];
    _titleBottomLine.backgroundColor = [UIColor colorWithHex:0xC8C7CC];
    [self addSubview:_titleBottomLine];
    
    _abstractLabel = [UILabel new];
    _abstractLabel.font = [UIFont systemFontOfSize:14];
    _abstractLabel.textColor = [UIColor newSecondTextColor];
    _abstractLabel.numberOfLines = 0;
    _abstractLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:_abstractLabel];
    
    _abstractBottomLine = [UIView new];
    _abstractBottomLine.backgroundColor = [UIColor colorWithHex:0xC8C7CC];
    [self addSubview:_abstractBottomLine];
    
    _webView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 0, kScreen_bound_width - padding_left - padding_right, 10) usingUIWebView:NO];
    [_webView.scrollView setBounces:NO];
    [_webView.scrollView setScrollEnabled:NO];
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [self addSubview:_webView];

    [self layoutFrameSubView];
}

- (void)layoutFrameSubView
{
    /** userInfo */
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self).offset(0);
        make.height.equalTo(@bg_View_Height);
    }];
    
    [_relationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(button_width));
        make.height.equalTo(@(button_height));
        make.centerY.equalTo(_bottomView);
        make.right.equalTo(_bottomView).offset(-padding_right);
    }];
    
    [_portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_bottomView).offset(padding_left);
        make.top.equalTo(_bottomView).offset(padding_top);
        make.width.and.height.equalTo(@portrait_size);
    }];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bottomView).offset(padding_top);
        make.left.equalTo(_portraitView.mas_right).offset(portraitImageView_space_nameLb);
        make.right.equalTo(_bottomView).offset(-(button_width + padding_right));
    }];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userNameLabel.mas_bottom).offset(nameLb_SPACE_timeLb);
        make.left.equalTo(_bottomView).offset(60);
        make.right.equalTo(_bottomView).offset(-(button_width + padding_right));
    }];

    [_userInfoBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.equalTo(_bottomView.mas_bottom).offset(0);
        make.height.equalTo(@0.5);
    }];

    
    /** title */
    [_iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@iconLb_height);
        make.top.equalTo(_userInfoBottomLine.mas_bottom).with.offset(0);
        make.left.and.right.equalTo(self).with.offset(0);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(padding_left);
        make.right.equalTo(self).with.offset(-(padding_right));
        make.top.equalTo(_iconLabel.mas_bottom);
    }];

    
    /** viewCount */
    [_viewCountIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(padding_left);
        make.top.equalTo(_titleLabel.mas_bottom).offset(titleLb_SPACE_CountBar);
        make.width.equalTo(@icon_width);
        make.height.equalTo(@icon_height);
    }];
    [_viewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewCountIcon.mas_right).offset(countImageView_space_countLb);
        make.centerY.mas_equalTo(_viewCountIcon.mas_centerY);
        make.height.equalTo(@15);
    }];
    
    [_commentIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewCountLabel.mas_right).offset(count_space_count);
        make.centerY.mas_equalTo(_viewCountIcon.mas_centerY);
        make.width.equalTo(@icon_width);
        make.height.equalTo(@icon_height);
    }];
    [_commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_commentIcon.mas_right).offset(countImageView_space_countLb);
        make.centerY.mas_equalTo(_viewCountIcon.mas_centerY);
        make.height.equalTo(@15);
    }];
    [_titleBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewCountLabel.mas_bottom).with.offset(padding_bottom);
        make.left.equalTo(self).with.offset(padding_left);
        make.right.equalTo(self).with.offset(-(padding_right));
        make.height.equalTo(@0.5);
    }];
    
    
    /** abstract */
    [_abstractLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleBottomLine.mas_bottom).offset(padding_bottom);
        make.left.equalTo(self).with.offset(padding_left);
        make.right.equalTo(self).with.offset(-(padding_right));
    }];
    [_abstractBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_abstractLabel.mas_bottom).offset(padding_bottom);
        make.left.equalTo(self).with.offset(padding_left);
        make.right.equalTo(self).with.offset(-(padding_right));
        make.height.equalTo(@0.5);
    }];
    
    /** webView */
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_abstractBottomLine.mas_bottom).with.offset(padding_bottom);
        make.left.equalTo(self).with.offset(padding_left);
        make.right.equalTo(self).with.offset(-(padding_right));
        make.bottom.equalTo(self).with.offset(-(padding_bottom));
    }];
}

- (void)setBlogDetail:(OSCBlogDetail *)blogDetail
{
    _blogDetail = blogDetail;
    [_portraitView loadPortrait:[NSURL URLWithString:blogDetail.authorPortrait]];
    _userNameLabel.text = blogDetail.author;
    _timeLabel.text = blogDetail.pubDate;

    switch (blogDetail.authorRelation) {
        case 1://双方互为粉丝
        case 2://你单方面关注他
            [_relationButton setTitle:@"已关注" forState:UIControlStateNormal];
            break;
        case 3://他单方面关注我
        case 4: //互不关注
            [_relationButton setTitle:@"关注" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    _iconLabel.attributedText = [self iconAttributedString:blogDetail];
    _titleLabel.text = blogDetail.title;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)blogDetail.commentCount];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)blogDetail.viewCount];
    if (blogDetail.abstract.length > 0) {
        _abstractLabel.text = blogDetail.abstract;
    } else {
        _abstractLabel.text = @"无简介";
    }
}

- (NSMutableAttributedString *)iconAttributedString:(OSCBlogDetail *)blogDetail
{
    NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] init];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString* systemDateStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"systemDate"];
    if (!systemDateStr) { systemDateStr = [formatter stringFromDate:[NSDate date]]; }
    
    NSDate* date = [formatter dateFromString:blogDetail.pubDate];
    NSDate* systemDate = [formatter dateFromString:systemDateStr];
    NSDate *subDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", [systemDateStr componentsSeparatedByString:@" "][0]]];
    int timeSecond = [systemDate timeIntervalSince1970] - [date timeIntervalSince1970];
    int subTime = [systemDate timeIntervalSince1970] - [subDate timeIntervalSince1970];
    
    if (timeSecond <= subTime) {
        NSTextAttachment* textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:@"ic_label_today"];
        [textAttachment adjustY:-3];
        [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
        [mutableAttributeString appendAttributedString:[[NSAttributedString alloc]initWithString:@" "]];
    }
    
    if (blogDetail.recommend) {
        NSTextAttachment* textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:@"ic_label_recommend"];
        [textAttachment adjustY:-3];
        [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
        [mutableAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    if (blogDetail.original) {
        NSTextAttachment* textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:@"ic_label_originate"];
        [textAttachment adjustY:-3];
        [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    } else {
        NSTextAttachment* textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:@"ic_label_reprint"];
        [textAttachment adjustY:-3];
        [mutableAttributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment]];
    }
    
    return mutableAttributeString;
}

@end
