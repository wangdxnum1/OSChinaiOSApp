//
//  TeamActivityCell.h
//  iosapp
//
//  Created by chenhaoxiang on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamActivity;
@class TTTAttributedLabel;

@interface TeamActivityCell : UITableViewCell

@property (nonatomic, strong) TTTAttributedLabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *timeLabel;

- (void)setContentWithActivity:(TeamActivity *)activity;

@end
