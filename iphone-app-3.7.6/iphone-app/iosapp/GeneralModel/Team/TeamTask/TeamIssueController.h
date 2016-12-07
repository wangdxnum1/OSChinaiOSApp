//
//  TeamIssueController.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"
typedef NS_ENUM(int, IssueState)
{
    IssueStateAll,
    IssueStateOpened,
    IssueStateUnderway,
    IssueStateClosed,
    IssueStateAccepted,
    IssueStateOutdate,
};

const NSArray *___kIssueStates;
#define kIssueStatesGet (___kIssueStates == nil ? ___kIssueStates = @[@"all",@"opened",@"underway",@"closed",@"accepted",@"outdate"]: ___kIssueStates)

#define kIssueStatesString(IssueState) ([kIssueStatesGet objectAtIndex:IssueState])

@interface TeamIssueController : OSCObjsViewController

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID userID:(int64_t)userID source:(NSString*)source andCatalogID:(int64_t)catalogID;
- (instancetype)initWithTeamID:(int)teamID;

- (instancetype)initWithTeamID:(int)teamID userID:(int64_t)userID andIssueState:(IssueState)issueState;

@end
