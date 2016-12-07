//
//  WeeklyReportContentViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 5/5/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "HorizonalTableViewController.h"
#import "WeeklyReportTitleBar.h"

@interface WeeklyReportContentViewController : HorizonalTableViewController

@property (nonatomic, strong) WeeklyReportTitleBar *titleBar;

- (instancetype)initWithTeamID:(int)teamID;
- (void)fetchPreviousReportTable;

@end
