//
//  WeeklyReportContentCell.m
//  iosapp
//
//  Created by AeternChan on 5/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamDetailContentCell.h"
#import "TeamWeeklyReportDetail.h"
#import "TeamActivity.h"
#import "Utils.h"

@implementation TeamDetailContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor themeColor];
        
        [self setLayout];
    }
    return self;
}


- (void)setLayout
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.userInteractionEnabled = YES;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont boldSystemFontOfSize:14];
    _authorLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_authorLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_contentLabel];
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _contentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]-10-[_contentLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_contentLabel]-8-|" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-5-[_authorLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_authorLabel]-5-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
}

- (void)setContentWithReportDetail:(TeamWeeklyReportDetail *)detail
{
    [_portrait loadPortrait:detail.author.portraitURL];
    _authorLabel.text = detail.author.name;
    _timeLabel.text = [detail.createTime timeAgoSinceNow];
    self.contentLabel.attributedText = detail.summary;
}

- (void)setContentWithActivity:(TeamActivity *)activity
{
    [_portrait loadPortrait:activity.author.portraitURL];
    _authorLabel.text = activity.author.name;
    _timeLabel.text = [activity.createTime timeAgoSinceNow];
    _contentLabel.attributedText = activity.attributedDetail;
}

@end
