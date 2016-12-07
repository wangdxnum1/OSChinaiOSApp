//
//  TweetDetailsWithBottomBarViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 1/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomBarViewController.h"
#import "OSCTweet.h"


@interface TweetDetailsWithBottomBarViewController : UIViewController

- (instancetype)initWithTweetID:(int64_t)tweetID;
////新的初始化方法
//- (instancetype)initWithTweet:(OSCTweet*)tweet;
@end
