//
//  TeamActivityViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamActivityViewController.h"
#import "TeamAPI.h"
#import "TeamActivity.h"
#import "TeamActivityCell.h"
#import "TeamActivityDetailViewController.h"


static NSString * const kActivityCellID = @"TeamActivityCell";

@interface TeamActivityViewController ()

@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic,assign) int teamID;

@end

@implementation TeamActivityViewController

- (instancetype)initWithTeamID:(int)teamID
{
    if (self = [super init]) {
        _teamID = teamID;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&type=all&pageIndex=%lu", TEAM_PREFIX, TEAM_ACTIVITY_LIST, teamID, (unsigned long)page];
        };
        
        self.objClass = [TeamActivity class];
    }
    
    return self;
}

#pragma mark --某个团队项目的动态

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID andSource:(NSString*)source
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@?teamid=%d&projectid=%d&source=%@&type=all&pageIndex=%lu", TEAM_PREFIX, TEAM_PROJECT_ACTIVE_LIST, teamID, projectID, source,(unsigned long)page];
            return urlString;
        };
        
        _teamID = teamID;
        self.objClass = [TeamActivity class];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"团队动态";
    [self.tableView registerClass:[TeamActivityCell class] forCellReuseIdentifier:kActivityCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"actives"] childrenWithTag:@"active"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamActivity *activity = self.objects[indexPath.row];
    
    self.label.attributedText = activity.attributedTitle;
    
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
    
    return height + 63;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kActivityCellID forIndexPath:indexPath];
    TeamActivity *activity = self.objects[indexPath.row];
    [cell setContentWithActivity:activity];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TeamActivity *activity = self.objects[indexPath.row];
    TeamActivityDetailViewController *detailVC = [[TeamActivityDetailViewController alloc] initWithActivity:activity andTeamID:_teamID];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}





@end
