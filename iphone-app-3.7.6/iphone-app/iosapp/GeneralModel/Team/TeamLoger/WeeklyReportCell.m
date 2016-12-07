//
//  WeeklyReportCell.m
//  iosapp
//
//  Created by chenhaoxiang on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportCell.h"
#import "Utils.h"
#import "TeamWeeklyReport.h"

@implementation WeeklyReportCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 0;
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.textColor = [UIColor nameColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_nameLabel];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_titleLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _commentLabel = [UILabel new];
    _commentLabel.font = [UIFont systemFontOfSize:12];
    _commentLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_commentLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _nameLabel, _portrait, _timeLabel, _commentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_nameLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_nameLabel]-8-[_titleLabel]-8-[_timeLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_titleLabel]-8-|" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]->=0-[_commentLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
}


- (void)setContentWithWeeklyReport:(TeamWeeklyReport *)weeklyReport
{
    _titleLabel.attributedText = weeklyReport.attributedTitle;
    _nameLabel.text = weeklyReport.author.name;
    [_portrait loadPortrait:weeklyReport.author.portraitURL];
    _timeLabel.attributedText = [Utils attributedTimeString:weeklyReport.createTime];
    _commentLabel.attributedText = [Utils attributedCommentCount:weeklyReport.replyCount];
}


@end
