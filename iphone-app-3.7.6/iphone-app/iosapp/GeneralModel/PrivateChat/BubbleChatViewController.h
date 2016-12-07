//
//  BubbleChatViewController.h
//  iosapp
//
//  Created by ChanAetern on 2/15/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomBarViewController.h"

@interface BubbleChatViewController : BottomBarViewController

- (instancetype)initWithUserID:(NSInteger)userID andUserName:(NSString *)userName;

@end
