//
//  WeeklyReportTableViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface WeeklyReportTableViewController : OSCObjsViewController

@property (nonatomic, readonly, assign) NSInteger year;
@property (nonatomic, readonly, assign) NSInteger week;

- (instancetype)initWithTeamID:(int)teamID year:(NSInteger)year andWeek:(NSInteger)week;

@end
