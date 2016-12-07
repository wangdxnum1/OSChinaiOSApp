//
//  TimeLineNodeCell.m
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TimeLineNodeCell.h"
#import "Utils.h"

static const int timelineColor = 0xA5A7A6;

@implementation TimeLineNodeCell

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
    UIView *node = [UIView new];
    node.backgroundColor = [UIColor colorWithHex:0xEEEEEE];
    [node setBorderWidth:2 andColor:[UIColor colorWithHex:timelineColor]];
    [node setCornerRadius:10];
    [self.contentView addSubview:node];
    
    UIView *innerNode = [UIView new];
    innerNode.backgroundColor = [UIColor colorWithHex:timelineColor];
    [innerNode setCornerRadius:5];
    [self.contentView addSubview:innerNode];
    
    _dayLabel = [UILabel new];
    _dayLabel.font = [UIFont systemFontOfSize:15];
    _dayLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:_dayLabel];
    
    _upperLine = [UIView new];
    _upperLine.backgroundColor = [UIColor colorWithHex:timelineColor];
    [self.contentView addSubview:_upperLine];
    
    _underLine = [UIView new];
    _underLine.backgroundColor = [UIColor colorWithHex:timelineColor];
    [self.contentView addSubview:_underLine];
    
    _contentLabel = [UILabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_contentLabel];

    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(node, innerNode, _dayLabel, _upperLine, _underLine, _contentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_upperLine(10)][node(20)][_underLine]|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_dayLabel(45)]-8-[node(20)]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[node]-8-[_contentLabel]-10-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_contentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                    toItem:_dayLabel     attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_upperLine(3)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_underLine(3)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[innerNode(10)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[innerNode(10)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:innerNode attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                                    toItem:node      attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:innerNode attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                                    toItem:node      attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)setContentWithString:(NSAttributedString *)HTML
{
    _contentLabel.attributedText = HTML;
}

@end
