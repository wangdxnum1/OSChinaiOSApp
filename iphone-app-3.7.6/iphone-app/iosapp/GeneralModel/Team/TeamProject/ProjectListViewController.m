//
//  ProjectListViewController.m
//  iosapp
//
//  Created by Holden on 15/4/27.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "ProjectListViewController.h"
#import "Config.h"
#import "ProjectCell.h"
#import "TeamAPI.h"
#import "TeamProject.h"
#import "SwipableViewController.h"
#import "TeamIssueListViewController.h"
#import "TeamMemberViewController.h"
#import "TeamActivityViewController.h"

static NSString *kProjectCellID = @"ProjectCell";

@interface ProjectListViewController ()

@end

@implementation ProjectListViewController


- (instancetype)initWithTeamId:(int)teamId
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url =[NSString stringWithFormat:@"%@%@?teamid=%d", OSCAPI_PREFIX, TEAM_PROJECT_LIST,teamId];
            return url;
        };
        
        __weak typeof(self) weakSelf = self;
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            weakSelf.lastCell.status = LastCellStatusFinished;
        };
        
        self.objClass = [TeamProject class];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"projects"] childrenWithTag:@"project"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"团队项目";
    [self.tableView registerClass:[ProjectCell class] forCellReuseIdentifier:kProjectCellID];
}

#pragma mark - tableView things

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProjectCellID forIndexPath:indexPath];
    TeamProject *project = self.objects[indexPath.row];
    
    [cell setContentWithTeamProject:project];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamProject *project = self.objects[indexPath.row];
    
#if 0
    self.label.font = [UIFont systemFontOfSize:13];
    self.label.text = [NSString stringWithFormat:@"%d/%d", project.openedIssueCount, project.allIssueCount];
    CGFloat width = [self.label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
#endif
    
    self.label.font = [UIFont boldSystemFontOfSize:16];
    self.label.attributedText = project.attributedTitle;
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 80, MAXFLOAT)].height;
    
    return height + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TeamProject *project = self.objects[indexPath.row];
    
    SwipableViewController *teamProjectSVC = [[SwipableViewController alloc]
                                              initWithTitle:@"团队项目"
                                              andSubTitles:@[@"任务分组", @"动态", @"成员"]
                                              andControllers:@[
                                                               [[TeamIssueListViewController alloc] initWithTeamID:project.teamID projectID:project.gitID andSource:project.source],
                                                               [[TeamActivityViewController alloc]  initWithTeamID:project.teamID projectID:project.gitID andSource:project.source],
                                                               [[TeamMemberViewController alloc] initWithTeamID:project.teamID projectID:project.gitID andSource:project.source]
                                                               ]];
    
    [self.navigationController pushViewController:teamProjectSVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
