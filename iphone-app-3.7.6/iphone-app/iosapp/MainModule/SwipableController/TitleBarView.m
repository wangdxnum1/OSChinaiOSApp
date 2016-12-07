//
//  TitleBarView.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-20.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TitleBarView.h"
#import "UIColor+Util.h"

#define kMaxBtnWidth 80
#define kScreenSize [UIScreen mainScreen].bounds.size

@interface TitleBarView ()

@property (nonatomic,assign) BOOL isNeedScroll;

@end

@implementation TitleBarView

-(instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles andNeedScroll:(BOOL)isNeedScroll{
    _isNeedScroll = isNeedScroll;
    return [self initWithFrame:frame andTitles:titles];
}

- (instancetype)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self reloadAllButtonsOfTitleBarWithTitles:titles];
        self.showsHorizontalScrollIndicator = NO;
    }
    
    return self;
}

/**重置所有的btn*/
-(void)reloadAllButtonsOfTitleBarWithTitles:(NSArray *)titles{
    for (UIButton *btn in _titleButtons) {
        [btn removeFromSuperview];
    }
    
    _currentIndex = 0;
    _titleButtons = [NSMutableArray new];
    
    CGFloat buttonWidth = self.frame.size.width / titles.count;
    CGFloat buttonHeight = self.frame.size.height;
    if(titles.count * kMaxBtnWidth > self.frame.size.width){
        self.contentSize = CGSizeMake(titles.count * kMaxBtnWidth, self.frame.size.height);
        buttonWidth = kMaxBtnWidth;
    }else if(_isNeedScroll){
        self.contentSize = CGSizeMake(self.frame.size.width + 1, self.frame.size.height);
        buttonWidth = kMaxBtnWidth;
    }else{
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        
        button.frame = CGRectMake(buttonWidth * idx, 0, buttonWidth, buttonHeight);
        button.tag = idx;
        [button addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_titleButtons addObject:button];
        [self addSubview:button];
        [self sendSubviewToBack:button];
    }];
    UIButton *firstTitle = _titleButtons[0];
    [firstTitle setTitleColor:[UIColor newSectionButtonSelectedColor] forState:UIControlStateNormal];
}

- (void)onClick:(UIButton *)button
{
    if (_currentIndex != button.tag) {
        [self scrollToCenterWithIndex:button.tag];
        _titleButtonClicked(button.tag);
    }
}

- (void)scrollToCenterWithIndex:(NSInteger)index{
    UIButton *preTitle = _titleButtons[_currentIndex];
    [preTitle setTitleColor:[UIColor colorWithHex:0x909090] forState:UIControlStateNormal];
    _currentIndex = index;
    UIButton *firstTitle = _titleButtons[index];
    [firstTitle setTitleColor:[UIColor newSectionButtonSelectedColor] forState:UIControlStateNormal];
    UIButton *button = [self viewWithTag:index];
    if (self.contentSize.width > kScreenSize.width) {
        if (CGRectGetMidX(button.frame) < kScreenSize.width / 2) {
            [self setContentOffset:CGPointZero animated:YES];
        }else if (self.contentSize.width - CGRectGetMidX(button.frame) < kScreenSize.width / 2){
            [self setContentOffset:CGPointMake(self.contentSize.width - CGRectGetWidth(self.frame), 0) animated:YES];
        }else{
            CGFloat needScrollWidth = CGRectGetMidX(button.frame) - self.contentOffset.x - kScreenSize.width / 2;
            [self setContentOffset:CGPointMake(self.contentOffset.x + needScrollWidth, 0) animated:YES];
        }
    }
}

- (void)setTitleButtonsColor
{
    for (UIButton *button in self.subviews) {
        button.backgroundColor = [UIColor titleBarColor];
    }
}

@end
