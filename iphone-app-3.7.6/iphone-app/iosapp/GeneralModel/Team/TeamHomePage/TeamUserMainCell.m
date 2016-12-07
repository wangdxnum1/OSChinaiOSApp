//
//  TeamUserMainCell.m
//  iosapp
//
//  Created by chenhaoxiang on 4/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamUserMainCell.h"
#import "TeamUser.h"
#import "Utils.h"
#import "Config.h"

@interface TeamUserMainCell ()

@property (nonatomic, strong) UIView *buttonsBG;

@end

@implementation TeamUserMainCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.userInteractionEnabled = YES;
    [_portrait setCornerRadius:25];
    [self.contentView addSubview:_portrait];
    
    _greetingLabel = [UILabel new];
    _greetingLabel.font = [UIFont boldSystemFontOfSize:20];
    _greetingLabel.userInteractionEnabled = YES;
    _greetingLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_greetingLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:15];
    _timeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_timeLabel];
    
    
    /****** button ******/
    
    _buttonsBG = [UIView new];
    [self.contentView addSubview:_buttonsBG];
    _unfinishedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _overdueButton    = [UIButton buttonWithType:UIButtonTypeCustom];
    _underwayButton   = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishedButton   = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    
    NSArray *titles = @[@"待完成", @"过期的", @"进行中", @"已完成"];
    NSArray *colors = @[@(0xF9AA47), @(0xED6732), @(0x7FB86E), @(0x999999)];
    
    [@[_unfinishedButton, _overdueButton, _underwayButton, _finishedButton] enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button setTitle:[NSString stringWithFormat:@"0\n%@", titles[idx]]
                forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor colorWithHex:((NSNumber *)colors[idx]).intValue]
                     forState:UIControlStateNormal];
        [_buttonsBG addSubview:button];
    }];
}


- (void)setLayout
{
    UIView *horizonalLine = [UIView new];
    horizonalLine.backgroundColor = [UIColor lightGrayColor];
    UIView *verticalLine = [UIView new];
    verticalLine.backgroundColor = [UIColor lightGrayColor];
    [_buttonsBG addSubview:horizonalLine];
    [_buttonsBG addSubview:verticalLine];
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in _buttonsBG.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _greetingLabel, _timeLabel, _buttonsBG, horizonalLine, verticalLine,
                                                         _unfinishedButton, _underwayButton, _overdueButton, _finishedButton);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(50)]-20-[_buttonsBG]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[_portrait(50)]-8-[_greetingLabel]-20-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_greetingLabel]-5-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_buttonsBG     attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                                                    toItem:_greetingLabel attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_unfinishedButton][_overdueButton]|"
                                                                       options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                       metrics:nil views:views]];
    
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_unfinishedButton][_underwayButton]|"
                                                                       options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                       metrics:nil views:views]];
    
    [_buttonsBG addConstraint:[NSLayoutConstraint constraintWithItem:_buttonsBG        attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                              toItem:_unfinishedButton attribute:NSLayoutAttributeHeight multiplier:2 constant:0]];
    
    [_buttonsBG addConstraint:[NSLayoutConstraint constraintWithItem:_buttonsBG        attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                              toItem:_unfinishedButton attribute:NSLayoutAttributeWidth multiplier:2 constant:0]];
    
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_underwayButton][_finishedButton]|"
                                                                       options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                       metrics:nil views:views]];
    
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_overdueButton][_finishedButton]|"
                                                                       options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                       metrics:nil views:views]];
    
    
    /****** line ******/
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[verticalLine]|" options:0 metrics:nil views:views]];
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[verticalLine(1)]" options:0 metrics:nil views:views]];
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[horizonalLine]|" options:0 metrics:nil views:views]];
    [_buttonsBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[horizonalLine(1)]" options:0 metrics:nil views:views]];
    [_buttonsBG addConstraint:[NSLayoutConstraint constraintWithItem:_buttonsBG   attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                              toItem:verticalLine attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [_buttonsBG addConstraint:[NSLayoutConstraint constraintWithItem:_buttonsBG    attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                              toItem:horizonalLine attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)setContentWithUser:(TeamUser *)user withTarget:(UIViewController*)targetVC
{
    [_portrait setImage:[Config getPortrait]];
    
    NSDate *date = [NSDate date];
    NSString *greetingString;
    if (date.hour < 12 && date.hour >= 5) {
        greetingString = @"早上好";
    } else if (date.hour >= 12 && date.hour < 18) {
        greetingString = @"下午好";
    } else {
        greetingString = @"晚上好";
    }
    
    _greetingLabel.text = [NSString stringWithFormat:@"%@，%@", user.name, greetingString];
    
    NSString *dateString = [NSString stringWithFormat:@"%ld年%ld月%ld日", date.year, date.month, date.day];
    _timeLabel.text = [NSString stringWithFormat:@"今天是%@，%@", date.weekdayString, dateString];
    
    [_unfinishedButton setTitle:[NSString stringWithFormat:@"%d\n待完成", user.openedTaskCount] forState:UIControlStateNormal];
    [_overdueButton setTitle:[NSString stringWithFormat:@"%d\n过期的", user.outdateTaskCount] forState:UIControlStateNormal];
    [_underwayButton setTitle:[NSString stringWithFormat:@"%d\n进行中", user.underwayTaskCount] forState:UIControlStateNormal];
    [_finishedButton setTitle:[NSString stringWithFormat:@"%d\n已完成", user.finishedTaskCount] forState:UIControlStateNormal];
    
    _unfinishedButton.tag = 0;
    _underwayButton.tag = 1;
    _finishedButton.tag = 2;
    _overdueButton.tag = 0;
    
    [_unfinishedButton addTarget:targetVC action:@selector(selecteIssueType:) forControlEvents:UIControlEventTouchUpInside];
    [_overdueButton addTarget:targetVC action:@selector(selecteIssueType:) forControlEvents:UIControlEventTouchUpInside];
    [_underwayButton addTarget:targetVC action:@selector(selecteIssueType:) forControlEvents:UIControlEventTouchUpInside];
    [_finishedButton addTarget:targetVC action:@selector(selecteIssueType:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- 取消警告的作用，这里的方法不会被执行
-(void)selecteIssueType:(UIButton*)btn
{
}
@end
