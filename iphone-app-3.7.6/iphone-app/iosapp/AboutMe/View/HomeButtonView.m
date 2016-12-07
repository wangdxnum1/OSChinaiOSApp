//
//  HomeButtonView.m
//  iosapp
//
//  Created by 李萍 on 16/7/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "HomeButtonView.h"
#import "Utils.h"
#import <Masonry.h>

#define buttonWidth [UIScreen mainScreen].bounds.size.width * 0.25
#define redView_W_H 6
#define buttonHeight 30


@interface HomeButtonView ()

@property (nonatomic, strong) UIButton *tweetButton;
@property (nonatomic, strong) UIButton *collectionButton;
@property (nonatomic, strong) UIButton *followingButton;
@property (nonatomic, strong) UIButton *fanButton;

@property (nonatomic, strong) UILabel *tweetTitleLabel;
@property (nonatomic, strong) UILabel *collectionTitleLabel;
@property (nonatomic, strong) UILabel *followingTitleLabel;
@property (nonatomic, strong) UILabel *fanTitleLabel;

@end

@implementation HomeButtonView
@synthesize delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self layoutSubButton];
    }
    return self;
}

- (void)layoutSubButton
{
    _tweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _tweetButton.frame = CGRectMake(0, 1, buttonWidth, buttonHeight*2-1);
    [self buttonWithColor:[UIColor whiteColor] andFont:24 button:_tweetButton];
    _tweetButton.tag = 1;

    _tweetTitleLabel = [UILabel new];
    _tweetTitleLabel.frame = CGRectMake(0, buttonHeight, buttonWidth, buttonHeight);
    _tweetTitleLabel.text = @"动弹";
    _tweetTitleLabel.font = [UIFont systemFontOfSize:12];
    _tweetTitleLabel.textColor = [UIColor whiteColor];
    _tweetTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    
    _collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectionButton.frame = CGRectMake(buttonWidth, 1, buttonWidth, buttonHeight*2-1);
    [self buttonWithColor:[UIColor whiteColor] andFont:24 button:_collectionButton];
    _collectionButton.tag = 2;
    
    _collectionTitleLabel = [UILabel new];
    _collectionTitleLabel.frame = CGRectMake(buttonWidth, buttonHeight, buttonWidth, buttonHeight);
    _collectionTitleLabel.text = @"收藏";
    _collectionTitleLabel.font = [UIFont systemFontOfSize:12];
    _collectionTitleLabel.textColor = [UIColor whiteColor];
    _collectionTitleLabel.textAlignment = NSTextAlignmentCenter;
    

    _followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _followingButton.frame = CGRectMake(buttonWidth*2, 1, buttonWidth, buttonHeight*2-1);
    [self buttonWithColor:[UIColor whiteColor] andFont:24 button:_followingButton];
    _followingButton.tag = 3;
    
    _followingTitleLabel = [UILabel new];
    _followingTitleLabel.frame = CGRectMake(buttonWidth*2, buttonHeight, buttonWidth, buttonHeight);
    _followingTitleLabel.text = @"关注";
    _followingTitleLabel.font = [UIFont systemFontOfSize:12];
    _followingTitleLabel.textColor = [UIColor whiteColor];
    _followingTitleLabel.textAlignment = NSTextAlignmentCenter;
    

    _fanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fanButton.frame = CGRectMake(buttonWidth*3, 1, buttonWidth, buttonHeight*2-1);
    [self buttonWithColor:[UIColor whiteColor] andFont:24 button:_fanButton];
    _fanButton.tag = 4;
    
    _fanTitleLabel = [UILabel new];
    _fanTitleLabel.frame = CGRectMake(buttonWidth*3, buttonHeight, buttonWidth, buttonHeight);
    _fanTitleLabel.text = @"粉丝";
    _fanTitleLabel.font = [UIFont systemFontOfSize:12];
    _fanTitleLabel.textColor = [UIColor whiteColor];
    _fanTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_tweetButton];
    [self addSubview:_collectionButton];
    [self addSubview:_followingButton];
    [self addSubview:_fanButton];
    
    [self addSubview:_tweetTitleLabel];
    [self addSubview:_collectionTitleLabel];
    [self addSubview:_followingTitleLabel];
    [self addSubview:_fanTitleLabel];
    
    _redPointView = [UIView new];
    _redPointView.frame = CGRectMake(buttonWidth-16, 6, 6, 6);
    _redPointView.backgroundColor = [UIColor redColor];
    _redPointView.userInteractionEnabled = YES;
    _redPointView.layer.cornerRadius = 3;
    _redPointView.hidden = YES;
    [self.fanButton addSubview:_redPointView];
}

- (void)buttonWithColor:(UIColor *)color andFont:(CGFloat)font button:(UIButton *)button
{
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:font];
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    button.contentEdgeInsets = UIEdgeInsetsMake(6, 0, 0, 0);

    UIImage *image = [Utils imageWithColor:[UIColor colorWithHex:0x1EB050 alpha:0.8]];
    [button setBackgroundImage:image forState:UIControlStateHighlighted];
    image = [Utils imageWithColor:[UIColor clearColor]];
    [button setBackgroundImage:image forState:UIControlStateNormal];

    [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clickAction:(UIButton *)sender
{
    [delegate clickButtonAction:sender.tag];
}

#pragma mark - ButtonViewDelegate
- (void)clickButtonAction:(NSInteger)senderTag
{
    [delegate clickButtonAction:senderTag];
    
}

#pragma mark - data
- (void)setUserInfo:(OSCUserItem *)userInfo
{
    [_tweetButton setTitle:[Utils numberLimitString:(int)userInfo.statistics.tweet] forState:UIControlStateNormal];
    [_collectionButton setTitle:[Utils numberLimitString:(int)userInfo.statistics.collect] forState:UIControlStateNormal];
    [_followingButton setTitle:[Utils numberLimitString:(int)userInfo.statistics.follow] forState:UIControlStateNormal];
    [_fanButton setTitle:[Utils numberLimitString:(int)userInfo.statistics.fans] forState:UIControlStateNormal];
}

@end
