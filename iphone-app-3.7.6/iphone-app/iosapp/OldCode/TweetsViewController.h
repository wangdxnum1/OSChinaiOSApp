//
//  TweetsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(NSUInteger, TweetsType)
{
    TweetsTypeAllTweets,
    TweetsTypeHotestTweets,
    TweetsTypeOwnTweets,
};

@interface TweetsViewController : OSCObjsViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithTweetsType:(TweetsType)type;
- (instancetype)initWithUserID:(int64_t)userID;
- (instancetype)initWithSoftwareID:(int64_t)softwareID;
- (instancetype)initWithTopic:(NSString *)topic;

@end
