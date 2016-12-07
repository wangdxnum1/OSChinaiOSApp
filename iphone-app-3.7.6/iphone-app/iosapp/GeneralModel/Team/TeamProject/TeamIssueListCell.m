//
//  TeamIssueListCell.m
//  iosapp
//
//  Created by Holden on 15/4/29.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueListCell.h"
#import "UIColor+Util.h"
@implementation TeamIssueListCell


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
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor titleColor];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:_titleLabel];
    
    _detailLabel = [UILabel new];
    _detailLabel.textColor = [UIColor grayColor];
    _detailLabel.numberOfLines = 0;
    _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _detailLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:_detailLabel];
    
    _countLabel = [UILabel new];
    _countLabel.numberOfLines = 0;
    _countLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _countLabel.font = [UIFont systemFontOfSize:13];
    _countLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_countLabel];
    
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel,_detailLabel,_countLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-8-[_detailLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_titleLabel]-5-[_countLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_detailLabel]-8-|" options:0 metrics:nil views:views]];
    
}


@end
