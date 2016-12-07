//
//  SoftwareCell.m
//  iosapp
//
//  Created by ChanAetern on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "SoftwareCell.h"
#import "UIColor+Util.h"

@implementation SoftwareCell

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
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:_nameLabel];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _descriptionLabel.font = [UIFont systemFontOfSize:13];
    _descriptionLabel.textColor = [UIColor colorWithHex:0x4F4F4F];
    [self.contentView addSubview:self.descriptionLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_nameLabel, _descriptionLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_nameLabel]-5-[_descriptionLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_nameLabel]-8-|" options:0 metrics:nil views:views]];
}


@end
