//
//  TweetDetailsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentsViewController.h"


@interface TweetDetailsViewController : CommentsViewController

- (instancetype)initWithTweetID:(int64_t)tweetID;

@end
