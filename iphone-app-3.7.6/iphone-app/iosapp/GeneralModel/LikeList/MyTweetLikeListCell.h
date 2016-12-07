//
//  MyTweetLikeListCell.h
//  iosapp
//
//  Created by 李萍 on 15/4/9.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCMyTweetLikeList.h"

@interface MyTweetLikeListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *likeUserNameLabel;
@property (nonatomic, strong) UILabel *textlLikeLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *authorTweetLabel;

- (void)setContentWithMyTweetLikeList:(OSCMyTweetLikeList *)myLikeTweet;

@end
