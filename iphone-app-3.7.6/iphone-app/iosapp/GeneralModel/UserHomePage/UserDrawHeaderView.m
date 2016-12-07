//
//  UserDrawHeaderView.m
//  iosapp
//
//  Created by Graphic-one on 16/8/3.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UserDrawHeaderView.h"
#import "Utils.h"
#import "OSCUser.h"
#import "OSCUserItem.h"
#import "AppDelegate.h"
#import "QuartzCanvasView.h"

#import <Masonry.h>

#define screen_width [UIScreen mainScreen].bounds.size.width
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

@implementation UserDrawHeaderView{
    __weak UIView* _followsBtnAndFansBtn_colorLine;
    __weak QuartzCanvasView* _drawView;
    __weak UIView* _countView;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayout];
    }
    return self;
}

- (void)setLayout
{
    QuartzCanvasView* drawView = [[QuartzCanvasView alloc]initWithFrame:(CGRect){{0,0},self.bounds.size}];
    _drawView = drawView;
    _drawView.bgColor = [UIColor colorWithHex:0x24CF5F];
    _drawView.openRandomness = YES;
    _drawView.minimumRoundRadius = portrait_width * 0.5 + 30;
    _drawView.strokeColor = [UIColor colorWithHex:0x6FDB94];
    _drawView.offestCenter = (OffestCenter){0,-38};
    [self addSubview:_drawView];
    
    _imageBackView = [UIView new];
    _imageBackView.backgroundColor = [UIColor colorWithHex:0xEEEEEE];
    [_imageBackView setCornerRadius:background_white_border_width * 0.5];
    [self addSubview:_imageBackView];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:portrait_width * 0.5];
    _portrait.userInteractionEnabled = YES;
    [self addSubview:_portrait];
    
    _genderImageView = [UIImageView new];
    _genderImageView.contentMode = UIViewContentModeScaleAspectFit;
    _genderImageView.hidden = YES;
    [self addSubview:_genderImageView];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:20];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.numberOfLines = 2;
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self addSubview:_nameLabel];
    
    _signatureLabel = [[UILabel alloc]init];
    _signatureLabel.font = [UIFont systemFontOfSize:13];
    _signatureLabel.textAlignment = NSTextAlignmentCenter;
    _signatureLabel.numberOfLines = 2;
    _signatureLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self addSubview:_signatureLabel];
    
    _integralLabel = [[UILabel alloc]init];
    _integralLabel.font = [UIFont systemFontOfSize:13];
    _integralLabel.textAlignment = NSTextAlignmentCenter;
    _integralLabel.numberOfLines = 1;
    _integralLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    [self addSubview:_integralLabel];
    
    UIView* followsBtnAndFansBtn_colorLine = [[UIView alloc]init];
    followsBtnAndFansBtn_colorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    _followsBtnAndFansBtn_colorLine = followsBtnAndFansBtn_colorLine;
    [self addSubview:_followsBtnAndFansBtn_colorLine];
    
    
    [self addSubview:({
        _followsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followsBtn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        [_followsBtn setBackgroundImage:[UIImage imageNamed:@"bg_follow_normal"] forState:UIControlStateNormal];
        [_followsBtn setBackgroundImage:[UIImage imageNamed:@"bg_follow_pressed"] forState:UIControlStateHighlighted];
        _followsBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _followsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _followsBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _followsBtn;
    })];
    
    [self addSubview:({
        _fansBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fansBtn setTitleColor:[UIColor colorWithHex:0xEEEEEE] forState:UIControlStateNormal];
        [_fansBtn setBackgroundImage:[UIImage imageNamed:@"bg_fans_normal"] forState:UIControlStateNormal];
        [_fansBtn setBackgroundImage:[UIImage imageNamed:@"bg_fans_pressed"] forState:UIControlStateHighlighted];
        _fansBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _fansBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _fansBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _fansBtn;
    })];
    
    [self settingLayout];
}
#pragma mark ---
-(void)settingLayout{
    [_imageBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(screen_half_width - (background_white_border_width * 0.5));
        make.top.equalTo(self).with.offset(paddingTop);
        make.width.and.height.equalTo(@background_white_border_width);
    }];
    
    [_portrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(screen_half_width - (portrait_width * 0.5));
        make.top.equalTo(self).with.offset(paddingTop + 2);
        make.width.and.height.equalTo(@portrait_width);
    }];
    
    [_genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(screen_half_width + (background_white_border_width * 0.5) - genderImgView_width);
        make.top.equalTo(self).with.offset(paddingTop + background_white_border_height - genderImgView_height);
        make.width.and.height.equalTo(@genderImgView_height);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(32);
        make.right.equalTo(self).with.offset(-32);
        make.top.equalTo(_imageBackView.mas_bottom).with.offset(portrait_space_name);
    }];
    
    [_signatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(20);
        make.right.equalTo(self).with.offset(-20);
        make.top.equalTo(_nameLabel.mas_bottom).with.offset(name_space_signature);
    }];
    
    [_integralLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(32);
        make.right.equalTo(self).with.offset(-32);
        make.top.equalTo(_signatureLabel.mas_bottom).with.offset(signature_space_integral);
    }];
    
    [_followsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(screen_half_width - center_btn_width);
        make.top.equalTo(_integralLabel.mas_bottom).with.offset(integral_space_centerBtn);
        make.width.equalTo(@(center_btn_width + 1));
        make.height.equalTo(@center_btn_height);
    }];
    
    [_fansBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(screen_half_width);
        make.top.equalTo(_integralLabel.mas_bottom).with.offset(integral_space_centerBtn);
        make.width.equalTo(@center_btn_width);
        make.height.equalTo(@center_btn_height);
    }];
    
    [_followsBtnAndFansBtn_colorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(screen_half_width);
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
}


- (void)setContentWithUserItem:(OSCUserHomePageItem *)userItem{
    [_portrait loadPortrait:[NSURL URLWithString:userItem.portrait]];
    
    if (userItem.gender == 1) {//男
        [_genderImageView setImage:[UIImage imageNamed:@"ic_male"]];
        _genderImageView.hidden = NO;
    } else if (userItem.gender == 2) {//女
        [_genderImageView setImage:[UIImage imageNamed:@"ic_female"]];
        _genderImageView.hidden = NO;
    }else{//未知
        _genderImageView.hidden = YES;
    }
    
    _nameLabel.text = userItem.name;
    _signatureLabel.text = [NSString stringWithFormat:@"%@",userItem.desc];
    _integralLabel.text = [NSString stringWithFormat:@"积分 %ld",userItem.statistics.score];
    
    [_followsBtn setTitle:[NSString stringWithFormat:@"关注 %ld", userItem.statistics.follow] forState:UIControlStateNormal];
    [_fansBtn setTitle:[NSString stringWithFormat:@"粉丝 %ld", userItem.statistics.fans] forState:UIControlStateNormal];
}



@end
