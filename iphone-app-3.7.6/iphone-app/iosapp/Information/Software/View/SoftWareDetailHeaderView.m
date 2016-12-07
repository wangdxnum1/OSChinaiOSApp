//
//  SoftWareDetailHeaderView.m
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareDetailHeaderView.h"
#import "Utils.h"

#define PADDING_LEFT 16
#define PADDING_RIGHT PADDING_LEFT
#define PADDING_TOP 16
#define PADDING_BOTTOM PADDING_TOP
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SPACE_BUTTON 16
#define HEIGHT_BUTTON 37

@implementation SoftWareDetailHeaderView{
    __weak UIButton* _leftButton;
    __weak UIButton* _rightButton;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubViews];
        [self setLayoutSubViews];
    }
    return self;
}

#pragma mark --- setting subViews
-(void)setupSubViews{
    UIButton* leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.backgroundColor = [UIColor whiteColor];
    leftBtn.layer.masksToBounds = YES;
    leftBtn.layer.cornerRadius = 3;
    leftBtn.layer.borderWidth = 1;
    leftBtn.layer.borderColor = [UIColor colorWithHex:0xd6d6d6].CGColor;
    leftBtn.tag = 100;
    [leftBtn setTitle:@"软件官网" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [leftBtn setImage:[UIImage imageNamed:@"ic_website"] forState:UIControlStateNormal];
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    [leftBtn addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftBtn];
    _leftButton = leftBtn;
    
    
    UIButton* rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.backgroundColor = [UIColor whiteColor];
    rightBtn.layer.masksToBounds = YES;
    rightBtn.layer.cornerRadius = 3;
    rightBtn.layer.borderWidth = 1;
    rightBtn.layer.borderColor = [UIColor colorWithHex:0xd6d6d6].CGColor;
    rightBtn.tag = 200;
    [rightBtn setTitle:@"软件文档" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn setImage:[UIImage imageNamed:@"ic_documents"] forState:UIControlStateNormal];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    [rightBtn addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightBtn];
    _rightButton = rightBtn;
    
//    update BG Color
    [_leftButton addTarget:self action:@selector(updateButtonsTouchDownBgColor:) forControlEvents:UIControlEventTouchDown];
    [_leftButton addTarget:self action:@selector(updateButtonsTouchUpBgColor:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [_rightButton addTarget:self action:@selector(updateButtonsTouchDownBgColor:) forControlEvents:UIControlEventTouchDown];
    [_rightButton addTarget:self action:@selector(updateButtonsTouchUpBgColor:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
}

-(void)setLayoutSubViews{
    _leftButton.frame = (CGRect){{PADDING_LEFT,PADDING_TOP},{(SCREEN_WIDTH - PADDING_LEFT - PADDING_RIGHT - SPACE_BUTTON)*0.5,HEIGHT_BUTTON}};
    CGFloat buttonWidth = CGRectGetWidth(_leftButton.frame);
    _rightButton.frame = (CGRect){{(PADDING_LEFT + buttonWidth + SPACE_BUTTON),PADDING_TOP},{buttonWidth,HEIGHT_BUTTON}};
}



#pragma mark --- click method 
-(void)buttonDidClick:(UIButton* )button{
    if (button.tag == 100) {//leftButton
        if ([_delegate respondsToSelector:@selector(softWareDetailHeaderViewClickLeft:)]) {
            [_delegate softWareDetailHeaderViewClickLeft:self];
        }
    }else{//rightButton
        if ([_delegate respondsToSelector:@selector(softWareDetailHeaderViewClickRight:)]) {
            [_delegate softWareDetailHeaderViewClickRight:self];
        }
    }
}

#pragma mark --- change BG color 
-(void)updateButtonsTouchDownBgColor:(UIButton* )btn{
    btn.backgroundColor = [UIColor colorWithHex:0xeeeeee];
}
-(void)updateButtonsTouchUpBgColor:(UIButton* )btn{
    btn.backgroundColor = [UIColor whiteColor];
}


@end
