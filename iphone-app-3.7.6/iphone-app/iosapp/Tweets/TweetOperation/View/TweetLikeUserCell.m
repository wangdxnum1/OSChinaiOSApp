//
//  TweetLikeUserCell.m
//  iosapp
//
//  Created by 李萍 on 15/4/3.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TweetLikeUserCell.h"
#import "Utils.h"
#import "UIImageView+CornerRadius.h"

@implementation TweetLikeUserCell

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
//    [_portrait setCornerRadius:5.0];
    _portrait.layer.cornerRadius = 5;
    [_portrait zy_cornerRadiusRoundingRect];
    [self.contentView addSubview:_portrait];
    
    _userNameLabel = [UILabel new];
    _userNameLabel.font = [UIFont boldSystemFontOfSize:14];
    _userNameLabel.userInteractionEnabled = YES;
    _userNameLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_userNameLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _userNameLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_userNameLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
}

@end
