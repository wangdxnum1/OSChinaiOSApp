//
//  SyntheticalTitleBarView.m
//  iosapp
//
//  Created by 王恒 on 16/10/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SyntheticalTitleBarView.h"
#import "UIColor+Util.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define kAnimationTime 0.5

@interface SyntheticalTitleBarView ()

{
    TitleBarView *_titleBar;
    NSArray *_titleArray;
    UIButton *_addBtn;
}

@end

@implementation SyntheticalTitleBarView

- (instancetype)initWithFrame:(CGRect)frame
                   WithTitles:(NSArray *)titleArray{
    _titleArray = titleArray;
    self = [super initWithFrame:frame];
    if (self) {
        [self addContentView];
        self.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    }
    return self;
}

- (void)addContentView{
    _titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width - self.bounds.size.height - 10, self.bounds.size.height) andTitles:_titleArray andNeedScroll:YES];
    __weak typeof(self) weakSelf = self;
    _titleBar.titleButtonClicked = ^(NSUInteger index) {
        if([weakSelf.delegate respondsToSelector:@selector(titleBtnClickWithIndex:)]){
            [weakSelf.delegate titleBtnClickWithIndex:index];
        }
    };
    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addBtn.frame = CGRectMake(self.bounds.size.width - self.bounds.size.height - 5, 0, self.bounds.size.height, self.bounds.size.height);
    [_addBtn setImage:[UIImage imageNamed:@"ic_subscribe.pdf"] forState:UIControlStateNormal];
    _addBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [_addBtn addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addBtn];
    _titleBar.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    _titleBarFrame = _titleBar.frame;
    
    UIView *titleBackView = [[UIView alloc] initWithFrame:_titleBar.frame];
    [titleBackView addSubview:_titleBar];
    [self addSubview:titleBackView];
    CAGradientLayer *layer = [[CAGradientLayer alloc] init];
    layer.frame = _titleBar.frame;
    layer.locations = @[@(0.01),@(0.13),@(0.87),@(0.99)];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 0);
    layer.colors = @[(id)[UIColor clearColor].CGColor,(id)[UIColor whiteColor].CGColor,(id)[UIColor whiteColor].CGColor,(id)[UIColor clearColor].CGColor];
    titleBackView.layer.mask = layer;
}

- (void)addClick{
    _addBtn.selected = !_addBtn.selected;
    _addBtn.enabled = NO;
    if (_addBtn.selected) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration = kAnimationTime - 0.2;
        animation.repeatCount = 1;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.fromValue = @(0);
        animation.toValue = @(-M_PI/4 * 3);
        [_addBtn.layer addAnimation:animation forKey:@"showAni"];
    }else{
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration = kAnimationTime - 0.2;
        animation.repeatCount = 1;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.fromValue = @(-M_PI/4 * 3);
        animation.toValue = @(0);
        [_addBtn.layer addAnimation:animation forKey:@"hideAni"];
        if ([self.delegate respondsToSelector:@selector(closeSyntheticalTitleBarView)]) {
            [self.delegate closeSyntheticalTitleBarView];
        }
    }
    if ([self.delegate respondsToSelector:@selector(addBtnClickWithIsBeginEdit:)]) {
        [self.delegate addBtnClickWithIsBeginEdit:_addBtn.selected];
    }
}

- (void)reloadAllButtonsOfTitleBarWithTitles:(NSArray *)titles{
    [_titleBar reloadAllButtonsOfTitleBarWithTitles:titles];
}

- (void)ClickCollectionCellWithIndex:(NSInteger)index{
    _addBtn.enabled = NO;
    _addBtn.selected = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration = kAnimationTime - 0.2;
    animation.repeatCount = 1;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.fromValue = @(-M_PI/4 * 3);
    animation.toValue = @(0);
    [_addBtn.layer addAnimation:animation forKey:@"hideAni"];
    [_titleBar scrollToCenterWithIndex:index];
}

- (void)scrollToCenterWithIndex:(NSInteger)index{
    [_titleBar scrollToCenterWithIndex:index];
}

#pragma --mark animationDelegate
-(void)endAnimation{
    _addBtn.enabled = YES;
}

@end
