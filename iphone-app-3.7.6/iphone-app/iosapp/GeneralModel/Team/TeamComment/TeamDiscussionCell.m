//
//  TeamDiscussionCell.m
//  iosapp
//
//  Created by chenhaoxiang on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamDiscussionCell.h"
#import "Utils.h"
#import "TeamDiscussion.h"

@implementation TeamDiscussionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
    }
    return self;
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_titleLabel];
    
    _bodyLabel = [UILabel new];
    _bodyLabel.numberOfLines = 0;
    _bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _bodyLabel.font = [UIFont systemFontOfSize:13];
    _bodyLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_bodyLabel];
    
    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont systemFontOfSize:12];
    _authorLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_authorLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _commentLabel = [UILabel new];
    _commentLabel.font = [UIFont systemFontOfSize:12];
    _commentLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_commentLabel];
    
    _praiseLabel = [UILabel new];
    _praiseLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_praiseLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _bodyLabel, _titleLabel, _authorLabel, _timeLabel, _commentLabel, _praiseLabel);
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_titleLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-5-[_bodyLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bodyLabel]-5-[_authorLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_authorLabel]-10-[_timeLabel]->=10-[_praiseLabel]-10-[_commentLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
}


- (void)setContentWithDiscussion:(TeamDiscussion *)discussion
{
    _titleLabel.text = discussion.title;
    _bodyLabel.text = discussion.body;
    _authorLabel.text = discussion.author.name;
    [_portrait loadPortrait:discussion.author.portraitURL];
    _timeLabel.attributedText = [Utils attributedTimeString:discussion.createTime];
    _commentLabel.attributedText = [Utils attributedCommentCount:discussion.answerCount];
}


@end
