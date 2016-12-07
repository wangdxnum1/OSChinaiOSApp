//
//  TweetFriendsListViewController.h
//  iosapp
//
//  Created by 王晨 on 15/8/25.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCObjsViewController.h"

@interface TweetFriendsListViewController : OSCObjsViewController
@property (nonatomic, copy) void (^selectDone)(NSString *result);
@end
