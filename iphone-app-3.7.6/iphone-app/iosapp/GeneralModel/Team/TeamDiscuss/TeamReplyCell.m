//
//  TeamReplyCell.m
//  iosapp
//
//  Created by chenhaoxiang on 5/8/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamReplyCell.h"
#import "TeamReply.h"
#import "Utils.h"

@implementation TeamReplyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self initSubviews];
        [self setLayout];
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
    
    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont boldSystemFontOfSize:14];
    _authorLabel.textColor = [UIColor nameColor];
    _authorLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:_authorLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _appclientLabel = [UILabel new];
    _appclientLabel.font = [UIFont systemFontOfSize:12];
    _appclientLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_appclientLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_contentLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _contentLabel, _timeLabel, _appclientLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_authorLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_authorLabel]-5-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-[_timeLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-10-[_appclientLabel]->=8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
}


- (void)setContentWithReply:(TeamReply *)reply
{
    [_portrait loadPortrait:reply.author.portraitURL];
    _authorLabel.text = reply.author.name;
    _contentLabel.attributedText = reply.content;
    //_contentLabel.attributedText = reply.attributedContent;
    _timeLabel.attributedText = [Utils attributedTimeString:reply.createTime];
    _appclientLabel.attributedText = [Utils getAppclient:reply.appclient];
}



@end
