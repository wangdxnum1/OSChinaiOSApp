//
//  UserHeaderCell.h
//  iosapp
//
//  Created by ChanAetern on 2/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCUser;

@interface UserHeaderCell : UITableViewCell

@property (nonatomic, strong) UIView* imageBackView;
@property (nonatomic, strong) UIImageView* portrait;
@property (nonatomic, strong) UIImageView* genderImageView;

@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* signatureLabel;
@property (nonatomic, strong) UILabel* integralLabel;

@property (nonatomic, strong) UIButton* followsBtn;
@property (nonatomic, strong) UIButton* fansBtn;

@property (nonatomic, strong) UIButton* creditsButton;
@property (nonatomic, strong) UIButton* followsButton;
@property (nonatomic, strong) UIButton* fansButton;

- (void)setContentWithUser:(OSCUser *)user;

@end
