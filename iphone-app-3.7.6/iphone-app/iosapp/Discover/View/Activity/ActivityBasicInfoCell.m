//
//  ActivityBasicInfoCell.m
//  iosapp
//
//  Created by ChanAetern on 1/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ActivityBasicInfoCell.h"
#import "Utils.h"

@implementation ActivityBasicInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor themeColor];
        
        [self setUpSubviews];
        [self setLayout];
    }
    return self;
}

- (void)setUpSubviews
{
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_titleLabel];
    
    _timeLabel= [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.numberOfLines = 0;
    _timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_timeLabel];
    
    _locationLabel = [UILabel new];
    _locationLabel.font = [UIFont systemFontOfSize:13];
    _locationLabel.numberOfLines = 0;
    _locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _locationLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_locationLabel];
    
    _applicationButton = [UIButton new];
    [_applicationButton setTitle:@"我要报名" forState:UIControlStateNormal];
    [_applicationButton setBackgroundColor:[UIColor navigationbarColor]];//colorWithHex:0x15A230
    [_applicationButton setCornerRadius:5.0];
    [self.contentView addSubview:_applicationButton];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _timeLabel, _locationLabel, _applicationButton);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_titleLabel]-10-|" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel]-8-[_timeLabel]-8-[_locationLabel]-8-[_applicationButton]-10-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
}


@end
