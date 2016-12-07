//
//  TeamActivityDetailViewController.h
//  iosapp
//
//  Created by Holden on 15/5/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "BottomBarViewController.h"
#import "TeamRepliesBVC.h"

@class TeamActivity;

@interface TeamActivityDetailViewController : TeamRepliesBVC

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID;

@end
