//
//  OSCRandomGiftView.m
//  iosapp
//
//  Created by Graphic-one on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCRandomGiftView.h"
#import "OSCRandomMessage.h"
#import "UIImageView+Util.h"

#import <Masonry.h>

#define giftImageView_Size_WH 60
#define indicateImageView_W 30
#define descLabel_H 60

#define giftImageView_SPACE_descLabel 10

#define LEFT_PADDING 10

@interface OSCRandomGiftView ()
@property (nonatomic,weak) UIImageView* giftImageView;
@property (nonatomic,weak) UILabel* giftDescLabel;
@property (nonatomic,weak) UIImageView* indicateImageView;
@end

@implementation OSCRandomGiftView{
    BOOL _trackingTouch_giftImageView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)addSubViews{
    [self addSubview:({
        UIImageView* giftImageView = [UIImageView new];
        giftImageView.layer.borderWidth = 1;
        giftImageView.layer.borderColor = [UIColor grayColor].CGColor;
        _giftImageView = giftImageView;
        _giftImageView;
    })];
    
    [self addSubview:({
        UILabel* giftDescLabel = [UILabel new];
        giftDescLabel.numberOfLines = 2;
        giftDescLabel.font = [UIFont systemFontOfSize:15];
        _giftDescLabel = giftDescLabel;
        _giftDescLabel;
    })];
    
    [self addSubview:({
        UIImageView* indicateImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_arrow_right"]];
        indicateImageView.contentMode = UIViewContentModeCenter;
        _indicateImageView = indicateImageView;
        _indicateImageView;
    })];
}

- (void)layoutSubviews{
    [_giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(giftImageView_Size_WH));
        make.left.equalTo(self).offset(LEFT_PADDING);
        make.centerY.equalTo(self);
    }];
    
    [_giftDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_giftImageView.mas_right).offset(giftImageView_SPACE_descLabel);
        make.right.equalTo(self).offset(-indicateImageView_W);
        make.centerY.equalTo(self.mas_centerY);
        make.height.equalTo(@(descLabel_H));
    }];
    
    [_indicateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.equalTo(self);
        make.width.equalTo(@(indicateImageView_W));
        make.height.equalTo(self);
    }];
}

#pragma mark --- setting Model
- (void)setRandomGiftItem:(OSCRandomGift *)randomGiftItem{
    _randomGiftItem = randomGiftItem;
    
    [self.giftImageView loadPortrait:[NSURL URLWithString:randomGiftItem.pic]];
    self.giftDescLabel.text = randomGiftItem.name;
}

#pragma mark --- touch event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_giftImageView = NO;
    
    UITouch* t = touches.anyObject;
    CGPoint p1 = [t locationInView:_giftImageView];
    if (CGRectContainsPoint(_giftImageView.bounds, p1)) {
        _trackingTouch_giftImageView = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_giftImageView) {
        if ([_delegate respondsToSelector:@selector(randomGiftViewDidClickGiftImageView:)]) {
            [_delegate randomGiftViewDidClickGiftImageView:self];
        }
    }else{
        if ([_delegate respondsToSelector:@selector(randomGiftViewDidRandomGiftView:)]) {
            [_delegate randomGiftViewDidRandomGiftView:self];
        }
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_giftImageView) {
        [super touchesCancelled:touches withEvent:event];
    }
}

@end




