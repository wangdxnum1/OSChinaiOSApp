//
//  TeamDiscussionCell.h
//  iosapp
//
//  Created by chenhaoxiang on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamDiscussion;

@interface TeamDiscussionCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *praiseLabel;

- (void)setContentWithDiscussion:(TeamDiscussion *)discussion;


@end
