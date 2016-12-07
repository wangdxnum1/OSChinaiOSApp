//
//  ActivityCell.m
//  iosapp
//
//  Created by chenhaoxiang on 1/25/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ActivityCell.h"
#import "Utils.h"

@implementation ActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        self.contentView.backgroundColor = [UIColor newCellColor];
        [self initSubviews];
        [self setLayout];
    }
    return self;
}

- (void)initSubviews
{
    _posterView = [UIImageView new];
    _posterView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_posterView];
    
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_titleLabel];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.font = [UIFont systemFontOfSize:13];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _descriptionLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_descriptionLabel];
    
    //_tabImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-40, 0, 10, 10)];
    _tabImageView = [UIImageView new];
    //_tabImageView.contentMode = UIViewContentModeScaleAspectFill;
    _tabImageView.hidden = YES;
    [self.contentView addSubview:_tabImageView];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_posterView, _titleLabel, _descriptionLabel, _tabImageView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_posterView(40)]-8-[_titleLabel]-28-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil views:views]];
    
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel]-10-[_descriptionLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_posterView(60)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tabImageView(30)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_tabImageView(30)]|" options:0 metrics:nil views:views]];
}

- (void)prepareForReuse
{
    _tabImageView.hidden = YES;
}

@end
