//
//  TeamRepliesBVC.h
//  iosapp
//
//  Created by chenhaoxiang on 5/21/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BottomBarViewController.h"

typedef NS_ENUM(NSInteger, TeamReplyType)
{
    TeamReplyTypeDiary,
    TeamReplyTypeDiscuss,
    TeamReplyTypeIssue,
    TeamReplyTypeActivity,
};

@class TeamReply;

@interface TeamRepliesBVC : BottomBarViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

- (instancetype)initWithObjectID:(int)ID andType:(TeamReplyType)type;

- (void)fetchRepliesOnPage:(NSUInteger)page;

@end
