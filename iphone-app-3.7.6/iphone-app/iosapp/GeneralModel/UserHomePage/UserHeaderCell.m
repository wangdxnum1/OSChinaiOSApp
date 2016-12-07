//
//  UserHeaderCell.m
//  iosapp
//
//  Created by ChanAetern on 2/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "UserHeaderCell.h"
#import "Utils.h"
#import "OSCUser.h"
#import "AppDelegate.h"

#import <Masonry.h>

#define screen_half_width [UIScreen mainScreen].bounds.size.width * 0.5

#define paddingTop 82
#define portrait_space_name 8
#define name_space_signature 8
#define signature_space_integral 16
#define integral_space_centerBtn 16

#define background_white_border_width 82
#define background_white_border_height background_white_border_width
#define portrait_width 78
#define genderImgView_width 20
#define genderImgView_height genderImgView_width
#define center_btn_width 110
#define center_btn_height 32

@implementation UserHeaderCell{
    __weak UIView* _followsBtnAndFansBtn_colorLine;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithHex:0x00CD66];
        
        [self setLayout];
    }
    return self;
}

- (void)setLayout
{
    UIImageView *backgroundImage = [UIImageView new];
    NSString *imageName = @"bg_my-1";
    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        imageName = @"bg_my_dark";
    }
    
    backgroundImage.image = [UIImage imageNamed:imageName];
    self.backgroundView = backgroundImage;
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.image.size.width, backgroundImage.image.size.height)];
//    view.backgroundColor = [UIColor infosBackViewColor];
//    [backgroundImage addSubview:view];
    
    _imageBackView = [UIView new];
    _imageBackView.backgroundColor = [UIColor colorWithHex:0xEEEEEE];
    [_imageBackView setCornerRadius:background_white_border_width * 0.5];
    [self.contentView addSubview:_imageBackView];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:portrait_width * 0.5];
    _portrait.userInteractionEnabled = YES;
    [self.contentView addSubview:_portrait];
    
    _genderImageView = [UIImageView new];
    _genderImageView.contentMode = UIViewContentModeScaleAspectFit;
    _genderImageView.hidden = YES;
    [self.contentView addSubview:_genderImageView];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:20];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self.contentView addSubview:_nameLabel];
    
    _signatureLabel = [[UILabel alloc]init];
    _signatureLabel.font = [UIFont systemFontOfSize:13];
    _signatureLabel.textAlignment = NSTextAlignmentCenter;
    _signatureLabel.numberOfLines = 2;
    _signatureLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self.contentView addSubview:_signatureLabel];
    
    _integralLabel = [[UILabel alloc]init];
    _integralLabel.font = [UIFont systemFontOfSize:13];
    _integralLabel.textAlignment = NSTextAlignmentCenter;
    _integralLabel.numberOfLines = 1;
    _integralLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self.contentView addSubview:_integralLabel];
    
    UIView* followsBtnAndFansBtn_colorLine = [[UIView alloc]init];
    followsBtnAndFansBtn_colorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    _followsBtnAndFansBtn_colorLine = followsBtnAndFansBtn_colorLine;
    [self.contentView addSubview:_followsBtnAndFansBtn_colorLine];
    

    [self.contentView addSubview:({
        _followsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followsBtn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        [_followsBtn setBackgroundImage:[UIImage imageNamed:@"bg_follow_normal"] forState:UIControlStateNormal];
        [_followsBtn setBackgroundImage:[UIImage imageNamed:@"bg_follow_pressed"] forState:UIControlStateHighlighted];
        _followsBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _followsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _followsBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _followsBtn;
    })];
    
    [self.contentView addSubview:({
        _fansBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fansBtn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        [_fansBtn setBackgroundImage:[UIImage imageNamed:@"bg_fans_normal"] forState:UIControlStateNormal];
        [_fansBtn setBackgroundImage:[UIImage imageNamed:@"bg_fans_pressed"] forState:UIControlStateHighlighted];
        _fansBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _fansBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _fansBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _fansBtn;
    })];
    
    
    /** 底部横排按钮 */

    UIView *line = [UIView new];
    line.backgroundColor = [UIColor lineColor];
    [self.contentView addSubview:line];
    
    UIView *countView = [UIView new];
    [self.contentView addSubview:countView];
    
    _creditsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _followsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fansButton    = [UIButton buttonWithType:UIButtonTypeCustom];
    
    void (^setButtonStyle)(UIButton *, NSString *) = ^(UIButton *button, NSString *title) {
        [button setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:title forState:UIControlStateNormal];
        [countView addSubview:button];
    };
    
    setButtonStyle(_creditsButton, @"积分\n");
    setButtonStyle(_followsButton, @"关注\n");
    setButtonStyle(_fansButton,    @"粉丝\n");
    
    [self settingLayout];
#pragma mark --- 暂时性隐藏
    line.hidden = YES;
    countView.hidden = YES;
    _creditsButton.hidden = YES;
    _followsButton.hidden = YES;
    _fansButton.hidden = YES;
    
//    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
//    for (UIView *view in countView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
//    
//    NSDictionary *views = NSDictionaryOfVariableBindings(_imageBackView, _portrait, _genderImageView, _nameLabel, _creditsButton, _followsButton, _fansButton, countView, line);
//    NSDictionary *metrics = @{@"width": @([UIScreen mainScreen].bounds.size.width / 3)};
//    
//    ///背景白圈
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_imageBackView(54)]"
//                                                                   options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_imageBackView(54)]" options:0 metrics:nil views:views]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imageBackView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
//                                                          toItem:_portrait attribute:NSLayoutAttributeCenterX multiplier:1 constant:27]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imageBackView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
//                                                          toItem:_portrait attribute:NSLayoutAttributeCenterY multiplier:1 constant:27]];
//    
//    ////男女区分图标
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_genderImageView(15)]"
//                                                                   options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_genderImageView(15)]" options:0 metrics:nil views:views]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_portrait attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
//                                                          toItem:_genderImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:7.5]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_portrait attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
//                                                          toItem:_genderImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:7.5]];
//    
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portrait(50)]-8-[_nameLabel]-10-[line(1)]-4-[countView(50)]|"
//                                                                   options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[line]|" options:0 metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(50)]" options:0 metrics:nil views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[countView]|" options:0 metrics:nil views:views]];
//    
//    
//    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_creditsButton(width)]->=0-[_followsButton(width)]->=0-[_fansButton(width)]|"
//                                                                      options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
//    [countView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_creditsButton]|" options:0 metrics:nil views:views]];
}

#pragma mark --- 
-(void)settingLayout{
    [_imageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(screen_half_width - (background_white_border_width * 0.5));
        make.top.equalTo(self.contentView).with.offset(paddingTop);
        make.width.and.height.equalTo(@background_white_border_width);
    }];
    
    [_portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(screen_half_width - (portrait_width * 0.5));
        make.top.equalTo(self.contentView).with.offset(paddingTop + 2);
        make.width.and.height.equalTo(@portrait_width);
    }];
    
    [_genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(screen_half_width + (background_white_border_width * 0.5) - genderImgView_width);
        make.top.equalTo(self.contentView).with.offset(paddingTop + background_white_border_height - genderImgView_height);
        make.width.and.height.equalTo(@genderImgView_height);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(32);
        make.right.equalTo(self.contentView).with.offset(-32);
        make.top.equalTo(_imageBackView.mas_bottom).with.offset(portrait_space_name);
    }];
    
    [_signatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(32);
        make.right.equalTo(self.contentView).with.offset(-32);
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(name_space_signature);
    }];
    
    [_integralLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(32);
        make.right.equalTo(self.contentView).with.offset(-32);
        make.top.equalTo(_signatureLabel.mas_bottom).with.offset(signature_space_integral);
    }];
    
    [_followsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(screen_half_width - center_btn_width);
        make.top.equalTo(_integralLabel.mas_bottom).with.offset(integral_space_centerBtn);
        make.width.equalTo(@(center_btn_width + 1));
        make.height.equalTo(@center_btn_height);
    }];
    
    [_fansBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(screen_half_width);
        make.top.equalTo(_integralLabel.mas_bottom).with.offset(integral_space_centerBtn);
        make.width.equalTo(@center_btn_width);
        make.height.equalTo(@center_btn_height);
    }];
    
    [_followsBtnAndFansBtn_colorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(screen_half_width);
        make.top.equalTo(_integralLabel.mas_bottom).with.offset(integral_space_centerBtn + 6);
        make.width.equalTo(@1);
        make.height.equalTo(@20);
    }];
    
}

- (void)setContentWithUser:(OSCUser *)user
{
    [_portrait loadPortrait:user.portraitURL];
    
    if ([user.gender isEqualToString:@"男"]) {
        [_genderImageView setImage:[UIImage imageNamed:@"ic_male"]];
        _genderImageView.hidden = NO;
    } else if ([user.gender isEqualToString:@"女"]) {
        [_genderImageView setImage:[UIImage imageNamed:@"ic_female"]];
        _genderImageView.hidden = NO;
    }
    
    _nameLabel.text = user.name;
    _signatureLabel.text = [NSString stringWithFormat:@"上次登录：%@",[user.latestOnlineTime timeAgoSinceNow]];
    _integralLabel.text = [NSString stringWithFormat:@"积分 %d",user.score];
    
    [_followsBtn setTitle:[NSString stringWithFormat:@"关注 %d", user.followersCount] forState:UIControlStateNormal
    ];
    [_fansBtn setTitle:[NSString stringWithFormat:@"粉丝 %d", user.fansCount] forState:UIControlStateNormal];

    
    /** 底部横排按钮 */
    
//    [_creditsButton setTitle:[NSString stringWithFormat:@"积分\n%d", user.score]          forState:UIControlStateNormal];
//    [_followsButton setTitle:[NSString stringWithFormat:@"关注\n%d", user.followersCount] forState:UIControlStateNormal];
//    [_fansButton    setTitle:[NSString stringWithFormat:@"粉丝\n%d", user.fansCount]      forState:UIControlStateNormal];
}


@end
