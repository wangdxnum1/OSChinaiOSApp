//
//  TeamUserMainCell.h
//  iosapp
//
//  Created by chenhaoxiang on 4/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamUser;

@interface TeamUserMainCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *greetingLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *unfinishedButton;
@property (nonatomic, strong) UIButton *overdueButton;
@property (nonatomic, strong) UIButton *underwayButton;
@property (nonatomic, strong) UIButton *finishedButton;

- (void)setContentWithUser:(TeamUser *)user withTarget:(UIViewController*)targetVC;

@end
