//
//  TeamIssueListViewController.h
//  iosapp
//
//  Created by Holden on 15/4/29.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface TeamIssueListViewController : OSCObjsViewController

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID andSource:(NSString*)source;

@end
