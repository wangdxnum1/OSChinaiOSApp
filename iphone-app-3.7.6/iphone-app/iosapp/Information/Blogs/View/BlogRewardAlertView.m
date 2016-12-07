//
//  BlogRewardAlertView.m
//  iosapp
//
//  Created by 李萍 on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "BlogRewardAlertView.h"
#import "Utils.h"

#import <Masonry.h>


#define padding 15
#define view_height 403
#define view_height_normal 346

#define screen_H [UIScreen mainScreen].bounds.size.height
#define screen_W [UIScreen mainScreen].bounds.size.width
#define userPortrait_width 66

#define textField_height 45
//#define change_button_top_padding 73

#define buttonWidth (screen_W - padding * 2 - 20*2 - 12*2)/3.0

@interface BlogRewardAlertView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *textView;
@property (nonatomic, strong) UILabel *changeButton ; //更换zhifufangs

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation BlogRewardAlertView
@synthesize delegate;


CGFloat change_button_top_padding;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttons = [NSMutableArray new];
        
        change_button_top_padding = 73;
        
        [self layoutNewSubView];
    }
    return self;
}

- (void)layoutNewSubView
{
    _rewardAlertView = [[UIView alloc] initWithFrame:CGRectMake(padding, (screen_H - view_height_normal)*0.5, screen_W - padding * 2, view_height)];
    
    _rewardAlertView.backgroundColor = [UIColor whiteColor];
    _rewardAlertView.layer.cornerRadius = 3;
    _rewardAlertView.clipsToBounds = YES;
    [self addSubview:_rewardAlertView];
    
    [self layoutAlertViewSubs];
}

- (void)layoutAlertViewSubs
{
    _userImageView = [UIImageView new];
    _userImageView.backgroundColor = [UIColor redColor];
    _userImageView.layer.cornerRadius = userPortrait_width * 0.5;
    _userImageView.clipsToBounds = YES;
    [_rewardAlertView addSubview:_userImageView];
    
    [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_rewardAlertView.mas_top).with.offset(32);
        make.left.equalTo(_rewardAlertView.mas_left).with.offset(screen_W * 0.5 - 15 - userPortrait_width * 0.5);
        make.width.and.height.equalTo(@userPortrait_width);
    }];
    
    _nameLabel = [UILabel new];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.textColor = [UIColor colorWithHex:0x333333];
    _nameLabel.font = [UIFont systemFontOfSize:18];
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    [_rewardAlertView addSubview:_nameLabel];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userImageView.mas_bottom).with.offset(8);
        make.left.equalTo(_rewardAlertView.mas_left).with.offset(20);
        make.right.equalTo(_rewardAlertView.mas_right).with.offset(-20);
        make.height.equalTo(@19);
    }];
    
    UILabel *descLabel = [UILabel new];
    descLabel.text = @"每个人都不容易，感谢大家支持，祝好。";
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.textColor = [UIColor colorWithHex:0x666666];
    descLabel.font = [UIFont systemFontOfSize:15];
    descLabel.adjustsFontSizeToFitWidth = YES;
    [_rewardAlertView addSubview:descLabel];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(12);
        make.left.equalTo(_rewardAlertView.mas_left).with.offset(20);
        make.right.equalTo(_rewardAlertView.mas_right).with.offset(-20);
        make.height.equalTo(@16);
    }];
    
    NSArray *buttonTitle = @[@"¥5", @"¥10", @"其他金额"];
    
    [buttonTitle enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *fiveButton = [[UIButton alloc] initWithFrame:CGRectMake(20+(buttonWidth + 12) * idx, 175, buttonWidth, 40)];
        [fiveButton setTitle:buttonTitle[idx] forState:UIControlStateNormal];
        fiveButton.titleLabel.font = [UIFont systemFontOfSize:15];
        fiveButton.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
        fiveButton.layer.cornerRadius = 2;
        fiveButton.clipsToBounds = YES;
        [_rewardAlertView addSubview:fiveButton];
        
        fiveButton.tag = idx+1;
        [fiveButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttons addObject:fiveButton];
        
        if (fiveButton.tag == 3) {
            [self setButtonBorder:fiveButton clicked:YES];
        } else {
            [self setButtonBorder:fiveButton clicked:NO];
        }
    }];
    
    _textView = [UIView new];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.cornerRadius = 2;
    _textView.layer.borderColor = [UIColor colorWithHex:0xe6e6e6].CGColor;
    _textView.layer.borderWidth = 1;
    [_rewardAlertView addSubview:_textView];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descLabel.mas_bottom).with.offset(80);
        make.left.equalTo(_rewardAlertView.mas_left).with.offset(20);
        make.right.equalTo(_rewardAlertView.mas_right).with.offset(-20);
        make.height.equalTo(@(textField_height));
    }];
    
    UILabel *label = [UILabel new];
    label.text = @"¥";
    label.textColor = [UIColor colorWithHex:0xb2b2b2];
    label.font = [UIFont systemFontOfSize:18];
    [_textView addSubview:label];
    
    _textField = [UITextField new];
    _textField.text = @"20";
    _textField.placeholder = @"20";
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.delegate = self;
    [_textView addSubview:_textField];
    
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView.mas_top).with.offset(10);
        make.left.equalTo(_textView.mas_left).with.offset(13);
        make.bottom.equalTo(_textView.mas_bottom).with.offset(-10);
        make.right.equalTo(_textField.mas_left).with.offset(-5);
//        make.height.equalTo(@19);
        make.width.equalTo(@11);
    }];
    
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView.mas_top).with.offset(10);
        make.left.equalTo(label.mas_right).with.offset(5);
        make.bottom.equalTo(_textView.mas_bottom).with.offset(-10);
        make.right.equalTo(_textView.mas_right).with.offset(-10);
    }];
    
    
    _changeButton = [UILabel new];
    _changeButton.textColor = [UIColor colorWithHex:0x333333];
    _changeButton.font = [UIFont systemFontOfSize:12];
    _changeButton.textAlignment = NSTextAlignmentCenter;
    [_rewardAlertView addSubview:_changeButton];
    
    _changeButton.text = @"默认使用支付宝付款";
    /*
     _changeButton.userInteractionEnabled = YES;
     [_changeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAction)]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"使用微信付款，更换"];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor newSectionButtonSelectedColor] range:NSMakeRange(string.length-2, 2)];
    _changeButton.attributedText = string;
    */

    UIButton *rewardButton = [UIButton new];
    [rewardButton setTitle:@"打赏" forState:UIControlStateNormal];
    rewardButton.backgroundColor = [UIColor colorWithHex:0x24cf5f];
    [rewardButton setTitleColor:[UIColor colorWithHex:0xffffff] forState:UIControlStateNormal];
    rewardButton.titleLabel.font = [UIFont systemFontOfSize:17];
    rewardButton.layer.cornerRadius = 3;
    rewardButton.clipsToBounds = YES;
    [rewardButton addTarget:self action:@selector(rewardAction:) forControlEvents:UIControlEventTouchUpInside];
    [_rewardAlertView addSubview:rewardButton];
    rewardButton.tag = 5;
    
    [_changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(rewardButton.mas_top).with.offset(-20);
        make.left.equalTo(_rewardAlertView.mas_left).with.offset(20);
        make.right.equalTo(_rewardAlertView.mas_right).with.offset(-20);
        make.height.equalTo(@13);
    }];
    
    [rewardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_rewardAlertView.mas_bottom).with.offset(-32);
        make.left.equalTo(_rewardAlertView.mas_left).with.offset(20);
        make.right.equalTo(_rewardAlertView.mas_right).with.offset(-20);
        make.height.equalTo(@45);
    }];
    
}

#pragma mark - 设置边框及颜色
- (void)setButtonBorder:(UIButton *)button clicked:(BOOL)isClicked
{
    [button.layer setBorderWidth:1.0];
    if (isClicked) {
        button.layer.borderColor=[UIColor newSectionButtonSelectedColor].CGColor;
        [button setTitleColor:[UIColor newSectionButtonSelectedColor] forState:UIControlStateNormal];
    } else {
        button.layer.borderColor=[UIColor colorWithHex:0xcbcace].CGColor;
        [button setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    }
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textField) {
        _moneyNum = [_textField.text longLongValue] * 100;
    }
}

#pragma mark - button select Action

- (void)buttonAction:(UIButton *)sender
{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
    
    for (UIButton *button in _buttons) {
        if (button.tag == sender.tag) {
            [self setButtonBorder:button clicked:YES];
        } else {
            [self setButtonBorder:button clicked:NO];
        }
    }
    
    if (sender.tag == 3) {
        _textView.hidden = NO;
        change_button_top_padding = 73;
        _rewardAlertView.frame = CGRectMake(padding, (screen_H - view_height_normal)*0.5, screen_W - padding * 2, view_height);
    } else {
        _textView.hidden = YES;
        _textField.text = @"20";
        change_button_top_padding = 16;
        _rewardAlertView.frame = CGRectMake(padding, (screen_H - view_height_normal)*0.5, screen_W - padding * 2, view_height_normal);
    }
    
    switch (sender.tag) {
        case 1:
        {
            _moneyNum = 5;
            break;
        }
        case 2:
        {
            _moneyNum = 10;
            break;
        }
        case 3:
        {
            _moneyNum = [_textField.text longLongValue];
            break;
        }
            
        default:
            break;
    }
    
    [delegate rewardAlertView:self clickedButtonMoney:_moneyNum isChange:NO isReward:NO];
}

#pragma mark - changeAction
- (void)changeAction
{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    } else {
        
    }
    NSLog(@"更换");
    //暂不支持微信支付，默认支付宝支付
//    [delegate rewardAlertView:self clickedButtonMoney:0 isChange:YES isReward:NO];
}

#pragma mark - reward action
- (void)rewardAction:(UIButton *)button
{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    } else {
        if (_moneyNum > 0) {
            [delegate rewardAlertView:self clickedButtonMoney:_moneyNum*100 isChange:NO isReward:YES];
        }
    }
}

- (void)rewardAlertView:(id)alertView clickedButtonMoney:(long)money isChange:(BOOL)isChange isReward:(BOOL)isReward
{
    [delegate rewardAlertView:self clickedButtonMoney:money isChange:isChange isReward:isReward];
}

@end


