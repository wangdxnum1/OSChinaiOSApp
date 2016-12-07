
//
//  TeamIssueController.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamIssueController.h"
#import "TeamAPI.h"
#import "TeamIssue.h"
#import "TeamIssueCell.h"
#import "Utils.h"
#import "Config.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>

#import "TeamIssueDetailController.h"

static NSString * const kIssueCellID = @"IssueCell";

@interface TeamIssueController ()

@property (nonatomic, assign) int teamID;

@end


@implementation TeamIssueController

- (instancetype)initWithTeamID:(int)teamID
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?teamid=%d&project=-1&pageIndex=%lu&state=opened", TEAM_PREFIX, TEAM_ISSUE_LIST, teamID, (unsigned long)page];
            return url;
        };
        _teamID = teamID;
        self.objClass = [TeamIssue class];
    }
    
    return self;
}

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID userID:(int64_t)userID source:(NSString*)source andCatalogID:(int64_t)catalogID
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?uid=%lldll&teamid=%d&projectid=%d&source=%@&catalogid=%llu&pageIndex=%lu", TEAM_PREFIX, TEAM_ISSUE_LIST, userID, teamID, projectID, source, catalogID,(unsigned long)page];
            return url;

        };
        _teamID = teamID;
        self.objClass = [TeamIssue class];
    }
    
    return self;
}

#pragma mark --我的任务

- (instancetype)initWithTeamID:(int)teamID userID:(int64_t)userID andIssueState:(IssueState)issueState
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?uid=%lld&teamid=%d&pageIndex=%lu&state=%@", TEAM_PREFIX, TEAM_ISSUE_LIST, userID, teamID,(unsigned long)page,kIssueStatesString(issueState)];
            return url;
        };
        _teamID = teamID;
        self.objClass = [TeamIssue class];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[TeamIssueCell class] forCellReuseIdentifier:kIssueCellID];
    self.tableView.separatorColor = [UIColor separatorColor];
    self.lastCell.emptyMessage = @"暂无任务";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"issues"] childrenWithTag:@"issue"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamIssue *issue = self.objects[indexPath.row];
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    self.label.attributedText = issue.attributedIssueTitle;
    
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
    
    if (issue.hasExtraInfo) {height += 22;}
    
    return height + 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamIssueCell *cell = [tableView dequeueReusableCellWithIdentifier:kIssueCellID forIndexPath:indexPath];
    TeamIssue *issue = self.objects[indexPath.row];
    
    [cell setContentWithIssue:issue];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TeamIssue *issue = self.objects[indexPath.row];
    TeamIssueDetailController *tidc = [[TeamIssueDetailController alloc]initWithIssueId:issue.issueID];
    tidc.projectName = issue.project.projectName;
    [self.navigationController pushViewController:tidc animated:YES];
}


@end
