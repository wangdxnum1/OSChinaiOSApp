//
//  TweetDetailCell.h
//  iosapp
//
//  Created by Holden on 16/7/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCTweetItem;

@interface TweetDetailCell : UITableViewCell
@property (strong, nonatomic) UIImageView *userPortrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UITextView *descTextView;
@property (nonatomic, strong) UIImageView *tweetImageView;

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *likeCountIv;

@property (nonatomic, strong) UIImageView *commentImage;

@property (nonatomic, strong) OSCTweetItem *tweet;

@end
