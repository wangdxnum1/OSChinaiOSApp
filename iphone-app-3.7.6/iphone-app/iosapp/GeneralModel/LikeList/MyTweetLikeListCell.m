//
//  MyTweetLikeListCell.m
//  iosapp
//
//  Created by 李萍 on 15/4/9.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MyTweetLikeListCell.h"
#import "Utils.h"

@implementation MyTweetLikeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.userInteractionEnabled = YES;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _likeUserNameLabel = [UILabel new];
    _likeUserNameLabel.font = [UIFont boldSystemFontOfSize:14];
    _likeUserNameLabel.userInteractionEnabled = YES;
    _likeUserNameLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_likeUserNameLabel];
    
    _textlLikeLabel = [UILabel new];
    _textlLikeLabel.font = [UIFont boldSystemFontOfSize:14];
    _textlLikeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_textlLikeLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _authorTweetLabel = [UILabel new];
    _authorTweetLabel.numberOfLines = 0;
    _authorTweetLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _authorTweetLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_authorTweetLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _likeUserNameLabel, _textlLikeLabel, _timeLabel, _authorTweetLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_likeUserNameLabel]-5-[_timeLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_likeUserNameLabel]-3-[_textlLikeLabel]-5-[_authorTweetLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_timeLabel]->=0-[_authorTweetLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllRight metrics:nil views:views]];

}

- (void)setContentWithMyTweetLikeList:(OSCMyTweetLikeList *)myLikeTweet
{
    [_portrait loadPortrait:myLikeTweet.portraitURL];
    [_likeUserNameLabel setText:[NSString stringWithFormat:@"%@", myLikeTweet.name]];
    [_textlLikeLabel setText:[NSString stringWithFormat:@"赞了我的动弹："]];
    [_timeLabel setText:[myLikeTweet.date timeAgoSinceNow]];
    [_authorTweetLabel setAttributedText:myLikeTweet.authorAndBody];
    
}

@end
