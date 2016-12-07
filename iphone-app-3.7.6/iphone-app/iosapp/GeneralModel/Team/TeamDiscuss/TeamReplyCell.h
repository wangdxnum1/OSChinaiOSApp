//
//  TeamReplyCell.h
//  iosapp
//
//  Created by chenhaoxiang on 5/8/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamReply;

@interface TeamReplyCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *appclientLabel;

- (void)setContentWithReply:(TeamReply *)reply;

@end
