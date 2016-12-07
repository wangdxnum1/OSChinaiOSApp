//
//  MessageBubbleViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface MessageBubbleViewController : OSCObjsViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithUserID:(int64_t)userID andUserName:(NSString *)userName;

@end
