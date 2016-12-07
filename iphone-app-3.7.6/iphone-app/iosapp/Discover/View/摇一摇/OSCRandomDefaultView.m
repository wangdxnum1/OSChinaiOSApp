//
//  OSCRandomDefaultView.m
//  iosapp
//
//  Created by Graphic-one on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCRandomDefaultView.h"
#import "UIImageView+Util.h"
#import "OSCRandomMessage.h"

#import <Masonry.h>
#import <UIView+YYAdd.h>

#define msgImageView_Size_WH 60
#define indicateImageView_W 30
#define descLabel_H 50
#define timeLabel_H 15

#define LEFT_PADDING 10
#define RIGHT_PADDING LEFT_PADDING
#define TOP_PADDING 16
#define BOTTOM_PADDING TOP_PADDING

#define msgImageView_space_descLabel 10
#define msgImageView_space_timeLabel 10
#define descLabel_space_indicateImageView 10
#define timeLabel_space_indicateImageView 10

@interface OSCRandomDefaultView ()
@property (nonatomic,weak) UIImageView* msgImageView;
@property (nonatomic,weak) UILabel* descLabel;
@property (nonatomic,weak) UILabel* timeLabel;
@property (nonatomic,weak) UIImageView* indicateImageView;
@end

@implementation OSCRandomDefaultView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self stupSubViews];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)stupSubViews{

    [self addSubview:({
        UIImageView* msgImageView = [UIImageView new];
        msgImageView.clipsToBounds = YES;
        msgImageView.contentMode = UIViewContentModeScaleAspectFit;
        _msgImageView = msgImageView;
        _msgImageView;
    })];
    
    [self addSubview:({
        UILabel* descLabel = [UILabel new];
        descLabel.textColor = [UIColor blackColor];
        descLabel.font = [UIFont systemFontOfSize:15];
        descLabel.numberOfLines = 2;
        _descLabel = descLabel;
    })];
    
    [self addSubview:({
        UILabel* timeLabel = [UILabel new];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.numberOfLines = 1;
        _timeLabel = timeLabel;
    })];
    
    [self addSubview:({
        UIImageView* indicateImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_arrow_right"]];
        indicateImageView.contentMode = UIViewContentModeCenter;
        _indicateImageView = indicateImageView;
        _indicateImageView;
    })];

}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_msgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(msgImageView_Size_WH));
        make.left.equalTo(self).offset(LEFT_PADDING);
        make.centerY.equalTo(self);
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_msgImageView.mas_right).offset(msgImageView_space_descLabel);
        make.top.equalTo(_msgImageView.mas_top);
        make.right.equalTo(self).offset(-indicateImageView_W);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_msgImageView.mas_right).offset(msgImageView_space_timeLabel);
        make.bottom.equalTo(_msgImageView.mas_bottom);
        make.right.equalTo(self).offset(-indicateImageView_W);
    }];
    
    [_indicateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.top.equalTo(self);
        make.width.equalTo(@(indicateImageView_W));
        make.height.equalTo(self);
    }];
}

#pragma mark --- setting Model
- (void)setRandomMessageItem:(OSCRandomMessageItem *)randomMessageItem{
    _randomMessageItem = randomMessageItem;
    
    [self.msgImageView loadPortrait:[NSURL URLWithString:randomMessageItem.img]];
    self.descLabel.text = randomMessageItem.name;
    self.timeLabel.text = [NSString stringWithFormat:@"发布于 %@",[[NSDate dateFromString:randomMessageItem.pubDate] timeAgoSinceNow]];
}

#pragma mark --- touch event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch* t = [touches anyObject];
    CGPoint p1 = [t locationInView:self];
    if (CGRectContainsPoint(self.bounds, p1)) {
        if ([_delegate respondsToSelector:@selector(randomDefaultViewDidClickDefaultView:)]) {
            [_delegate randomDefaultViewDidClickDefaultView:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}

@end
