//
//  WeeklyReportTitleBar.m
//  iosapp
//
//  Created by AeternChan on 5/4/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportTitleBar.h"
#import "Utils.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

@interface WeeklyReportTitleBar ()

@property (nonatomic, strong) UILabel *weekLabel;

@property (nonatomic, assign) NSInteger currentWeek;

@end

@implementation WeeklyReportTitleBar

- (instancetype)initWithFrame:(CGRect)frame andWeek:(NSInteger)week
{
    self = [super init];
    
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor titleBarColor];
        
        [self setLayout];
        _weekLabel.text = [NSString stringWithFormat:@"第%ld周周报总览", (long)week];
        
        _currentWeek = [NSDate date].weekOfYear;
        if (_currentWeek == week) {_nextWeekBtn.enabled = NO;}
    }
    
    return self;
}

- (void)setLayout
{
    _weekLabel = [UILabel new];
    _weekLabel.textColor = [UIColor darkGrayColor];
    [self addSubview:_weekLabel];
    
    _previousWeekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _previousWeekBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:16];
    [_previousWeekBtn setTitleColor:[UIColor colorWithHex:0x1B9E36] forState:UIControlStateNormal];
    [_previousWeekBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_previousWeekBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAChevronLeft]
                      forState:UIControlStateNormal];
    [self addSubview:_previousWeekBtn];
    
    _nextWeekBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextWeekBtn.titleLabel.font = [UIFont fontAwesomeFontOfSize:16];
    [_nextWeekBtn setTitleColor:[UIColor colorWithHex:0x1B9E36] forState:UIControlStateNormal];
    [_nextWeekBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [_nextWeekBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAChevronRight]
                  forState:UIControlStateNormal];
    [self addSubview:_nextWeekBtn];
    
    for (UIView *view in self.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_weekLabel, _previousWeekBtn, _nextWeekBtn);
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self       attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                        toItem:_weekLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self       attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                        toItem:_weekLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_previousWeekBtn(15)]-8-[_weekLabel]-8-[_nextWeekBtn(15)]"
                                                                 options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

- (void)updateWeek:(NSInteger)week
{
    _weekLabel.text = [NSString stringWithFormat:@"第%ld周周报总览", (long)week];
    
    _nextWeekBtn.enabled = YES;
    _previousWeekBtn.enabled = YES;
    
    if (week == _currentWeek) {
        _nextWeekBtn.enabled = NO;
    } else if (week == 1) {
        _previousWeekBtn.enabled = NO;
    }
}

@end
