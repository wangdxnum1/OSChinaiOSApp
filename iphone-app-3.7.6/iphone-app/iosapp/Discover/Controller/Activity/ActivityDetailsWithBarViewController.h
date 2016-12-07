//
//  ActivityDetailsWithBarViewController.h
//  iosapp
//
//  Created by ChanAetern on 3/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BottomBarViewController.h"

@class OSCActivity;

@interface ActivityDetailsWithBarViewController : BottomBarViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithActivityID:(int64_t)activityID;

@end
