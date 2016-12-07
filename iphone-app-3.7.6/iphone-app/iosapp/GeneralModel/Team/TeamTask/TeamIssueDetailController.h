//
//  TeamIssueDetailController.h
//  iosapp
//
//  Created by Holden on 15/4/30.
//  Copyright (c) 2015年 oschina. All rights reserved.
//


#import "BottomBarViewController.h"
#import "TeamRepliesBVC.h"

@interface TeamIssueDetailController : TeamRepliesBVC
@property (nonatomic,copy)NSString *projectName;
- (instancetype)initWithIssueId:(int)issueId;
@end
