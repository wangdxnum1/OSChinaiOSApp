//
//  EventsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 11/29/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface EventsViewController : OSCObjsViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithCatalog:(int)catalog;
- (instancetype)initWithUserID:(int64_t)userID;
- (instancetype)initWithUserName:(NSString *)userName;

@end
