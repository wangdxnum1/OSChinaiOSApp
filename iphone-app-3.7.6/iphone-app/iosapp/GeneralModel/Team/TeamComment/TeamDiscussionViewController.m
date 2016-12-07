//
//  DiscussionViewController.m
//  iosapp
//
//  Created by AeternChan on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamDiscussionViewController.h"
#import "TeamAPI.h"
#import "TeamDiscussion.h"
#import "TeamDiscussionCell.h"
#import "DiscussionDetailsViewController.h"

static NSString * const kDiscussionCellID = @"TeamDiscussionCell";

@interface TeamDiscussionViewController ()

@property (nonatomic, assign) int teamID;

@end

@implementation TeamDiscussionViewController

- (instancetype)initWithTeamID:(int)teamID
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&pageIndex=%lu", TEAM_PREFIX, TEAM_DISCUSS_LIST, teamID, (unsigned long)page];
        };
        
        self.objClass = [TeamDiscussion class];
        
        _teamID = teamID;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"团队讨论";
    [self.tableView registerClass:[TeamDiscussionCell class] forCellReuseIdentifier:kDiscussionCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"discusses"] childrenWithTag:@"discuss"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamDiscussion *discussion = self.objects[indexPath.row];
    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    self.label.text = discussion.title;
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
    
    self.label.text = discussion.body;
    self.label.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
    
    return height + 43;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamDiscussionCell *cell = [tableView dequeueReusableCellWithIdentifier:kDiscussionCellID forIndexPath:indexPath];
    TeamDiscussion *discussion = self.objects[indexPath.row];
    
    [cell setContentWithDiscussion:discussion];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TeamDiscussion *discussion = self.objects[indexPath.row];
    
    [self.navigationController pushViewController:[[DiscussionDetailsViewController alloc] initWithDiscussionID:discussion.discussionID]
                                         animated:YES];
}




@end
