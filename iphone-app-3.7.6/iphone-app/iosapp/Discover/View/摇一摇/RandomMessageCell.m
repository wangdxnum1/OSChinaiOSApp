//
//  RandomMessageCell.m
//  iosapp
//
//  Created by ChanAetern on 1/21/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "RandomMessageCell.h"
#import "Utils.h"
#import "OSCRandomMessage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation RandomMessageCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self setUpSubViews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setUpSubViews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFill;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_contentLabel];
    
    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont systemFontOfSize:10];
    _authorLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_authorLabel];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:10];
    _commentCount.textColor = [UIColor grayColor];
    [self.contentView addSubview:_commentCount];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_timeLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _titleLabel, _contentLabel, _authorLabel, _commentCount, _timeLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-5-[_titleLabel]-5-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel]-8-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-[_authorLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_authorLabel]-20-[_commentCount]-20-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}


//- (void)setContentWithMessage:(OSCRandomMessage *)message
//{
//    [_portrait sd_setImageWithURL:message.portraitURL];
//    _titleLabel.text    = message.title;
//    _contentLabel.text  = message.detail;
//    _authorLabel.text   = [NSString stringWithFormat:@"作者：%@", message.author];
//    _commentCount.text  = [NSString stringWithFormat:@"评论：%d", message.commentCount];
//    _timeLabel.text     = [NSString stringWithFormat:@"时间：%@", [message.pubDate timeAgoSinceNow]];
//}


- (void)setContentWithMessage:(OSCRandomMessageItem *)message
{
    [_portrait sd_setImageWithURL:[NSURL URLWithString:message.img]];
    _titleLabel.text    = message.name;
    _contentLabel.text  = message.detail;
//    _authorLabel.text   = [NSString stringWithFormat:@"作者：%@", message.author];
//    _commentCount.text  = [NSString stringWithFormat:@"评论：%d", message.commentCount];
//    _timeLabel.text     = [NSString stringWithFormat:@"时间：%@", [message.pubDate timeAgoSinceNow]];
}


@end
