//
//  WeeklyReportCell.h
//  iosapp
//
//  Created by chenhaoxiang on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamWeeklyReport;

@interface WeeklyReportCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentLabel;

- (void)setContentWithWeeklyReport:(TeamWeeklyReport *)weeklyReport;

@end
