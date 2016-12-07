//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"
#import "Utils.h"

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
    __weak UILabel *_titleTextLabel;
    __weak UIImageView *_colorImageView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
    }
    
    return self;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
//    _titleLabelTextColor = titleLabelTextColor;
//    _titleLabel.textColor = titleLabelTextColor;
    
    _titleLabelTextColor = titleLabelTextColor;
    _titleTextLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleTextLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
//    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
    
    UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_banner_title"]];
    _colorImageView = imageView;
    [self.contentView addSubview:imageView];
    
    UILabel *titleTextLabel = [[UILabel alloc] init];
    _titleTextLabel = titleTextLabel;
    _titleTextLabel.backgroundColor = [UIColor clearColor];
//    _titleTextLabel.hidden = YES;
    [self.contentView addSubview:titleTextLabel];
    
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];

//    _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
    _titleTextLabel.text = [NSString stringWithFormat:@"   %@", title];

}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    
    CGFloat titleLabelW = self.sd_width;
    CGFloat titleLabelH = _titleLabelHeight;
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = self.sd_height - titleLabelH;
    _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
//    _titleLabel.hidden = !_titleLabel.text;
    _colorImageView.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    _titleTextLabel.frame = CGRectMake(titleLabelX, titleLabelY+20, titleLabelW-80, titleLabelH-20);
    
    if (_titleBackgroundLayerBool) {
        [self layerForCycleScrollViewTitle];
    }
    
}

/* 标题背景添加渐变色 */
- (void)layerForCycleScrollViewTitle
{
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.colors = @[
                     (__bridge id)[UIColor colorWithHex:0x000000 alpha:0.0].CGColor,
                     (__bridge id)[UIColor colorWithHex:0x000000 alpha:0.5].CGColor,
                     ];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 0.5);
    layer.frame = _titleLabel.bounds;
    
    [_titleLabel.layer addSublayer:layer];
}

@end
