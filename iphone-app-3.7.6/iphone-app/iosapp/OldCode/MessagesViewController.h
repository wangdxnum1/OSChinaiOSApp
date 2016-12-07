//
//  MessagesViewController.h
//  iosapp
//
//  Created by ChanAetern on 12/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface MessagesViewController : OSCObjsViewController

@property (nonatomic, copy) void (^didScroll)();

@end
