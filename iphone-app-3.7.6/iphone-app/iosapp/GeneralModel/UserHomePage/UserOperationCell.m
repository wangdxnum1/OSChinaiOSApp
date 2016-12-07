//
//  UserOperationCell.m
//  iosapp
//
//  Created by ChanAetern on 2/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "UserOperationCell.h"
#import "Utils.h"

@implementation UserOperationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self setLayout];
    }
    return self;
}

- (void)setLayout
{
    _loginTimeLabel = [UILabel new];
    _loginTimeLabel.textAlignment = NSTextAlignmentCenter;
    _loginTimeLabel.font = [UIFont systemFontOfSize:13];
    _loginTimeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_loginTimeLabel];
    
    _messageButton     = [UIButton buttonWithType:UIButtonTypeCustom];
    _followButton      = [UIButton buttonWithType:UIButtonTypeCustom];
    _blogsButton       = [UIButton buttonWithType:UIButtonTypeCustom];
    _informationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIView *buttonsView = [UIView new];
    void (^setButtonStyle)(UIButton *, NSString *) = ^(UIButton *button, NSString *title) {
        [button setBackgroundColor:[UIColor colorWithHex:0x00CD66]];
        [button setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [button setCornerRadius:3.0];
        [buttonsView addSubview:button];
    };
    setButtonStyle(_messageButton, @"私信");
    setButtonStyle(_followButton,  @"关注");
    
    [self.contentView addSubview:buttonsView];
    
    
    UIView *buttonsView2 = [UIView new];
    void (^setButtonStyle2)(UIButton *, NSString *) = ^(UIButton *button, NSString *title) {
        button.backgroundColor = [UIColor colorWithHex:0xE1E1E1];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitleColor:[UIColor colorWithHex:0x808080] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        [buttonsView2 addSubview:button];
    };
    setButtonStyle2(_blogsButton, @"博客");
    setButtonStyle2(_informationButton, @"资料");
    
    _messageButton.backgroundColor = [UIColor navigationbarColor];
    _followButton.backgroundColor = [UIColor navigationbarColor];
    _blogsButton.backgroundColor = [UIColor titleBarColor];
    _informationButton.backgroundColor = [UIColor titleBarColor];
    
    [self.contentView addSubview:buttonsView2];
    
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in buttonsView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    for (UIView *view in buttonsView2.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_loginTimeLabel, _messageButton, _followButton, _blogsButton, _informationButton, buttonsView, buttonsView2);
    NSDictionary *metrics = @{@"width": @([UIScreen mainScreen].bounds.size.width / 2)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_loginTimeLabel]-5-[buttonsView(35)]-5-[buttonsView2(35)]|"
                                                                             options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_loginTimeLabel]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[buttonsView(270)]" options:0 metrics:nil views:views]];
    
    [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_messageButton(110)]->=8-[_followButton(110)]-15-|"
                                                                        options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                        metrics:nil views:views]];
    [buttonsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_messageButton]|" options:0 metrics:nil views:views]];
    
    [buttonsView2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_blogsButton(width)][_informationButton(width)]|"
                                                                        options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                        metrics:metrics views:views]];
    [buttonsView2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_blogsButton]|" options:0 metrics:nil views:views]];
}

- (void)setFollowButtonByRelationship:(int)relationship
{
    if (relationship >= 3) {
//        [_followButton setBackgroundColor:[UIColor colorWithHex:0x00CD66]];
        [_followButton setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        [_followButton setTitle:@"关注" forState:UIControlStateNormal];
    } else {
        [_followButton setBackgroundColor:[UIColor colorWithHex:0xDDDDDD]];
        [_followButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_followButton setTitle:relationship == 1? @"取消互粉" : @"取消关注"
                       forState:UIControlStateNormal];
    }
}
     

@end
