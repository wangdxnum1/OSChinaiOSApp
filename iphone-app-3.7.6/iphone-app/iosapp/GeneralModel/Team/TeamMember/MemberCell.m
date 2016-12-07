//
//  MemberCell.m
//  iosapp
//
//  Created by chenhaoxiang on 3/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MemberCell.h"
#import "TeamMember.h"
#import "Utils.h"

@implementation MemberCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayout];
    }
    
    return self;
}

- (void)setLayout
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:30];
    [self.contentView addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:14];
    _nameLabel.textColor = [UIColor contentTextColor];
    [self.contentView addSubview:_nameLabel];
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(60)]-8-[_nameLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(60)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                                    toItem:_portrait        attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void)setContentWithMember:(TeamMember *)member
{
    [_portrait loadPortrait:member.portraitURL];
    _nameLabel.text = member.name;
}

@end
