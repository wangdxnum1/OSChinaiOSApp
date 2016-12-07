//
//  TeamActivityViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

@interface TeamActivityViewController : OSCObjsViewController

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID andSource:(NSString*)source;

- (instancetype)initWithTeamID:(int)teamID;

@end
