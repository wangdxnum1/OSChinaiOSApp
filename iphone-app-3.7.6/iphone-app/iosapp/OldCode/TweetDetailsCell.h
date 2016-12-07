//
//  TweetDetailsCell.h
//  iosapp
//
//  Created by ChanAetern on 1/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetDetailsCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *appclientLabel;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UILabel *likeListLabel;

@end
