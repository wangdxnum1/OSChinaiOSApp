//
//  TeamIssueListViewController.m
//  iosapp
//
//  Created by Holden on 15/4/29.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamIssueListViewController.h"
#import "TeamIssueController.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamIssueListCell.h"
#import "TeamIssueList.h"

static NSString *kTeamIssueListCellID = @"teamIssueListCell";

@interface TeamIssueListViewController ()

@property (nonatomic) int projectID;
@property (nonatomic) int teamID;
@property (nonatomic, copy) NSString *source;

@end

@implementation TeamIssueListViewController

- (instancetype)initWithTeamID:(int)teamID projectID:(int)projectID andSource:(NSString *)source
{
    if (self = [super init]) {
        _projectID = projectID;
        _teamID = teamID;
        _source = source;
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&teamid=%d&projectid=%d&source=%@", OSCAPI_PREFIX, TEAM_PROJECT_CATALOG_LIST,
                                                                                                 [Config getOwnID], teamID, projectID, source];
        };
        
        __weak typeof(self) weakSelf = self;
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            weakSelf.lastCell.status = LastCellStatusFinished;
        };
        
        self.objClass = [TeamIssueList class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"catalogs"] childrenWithTag:@"catalog"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[TeamIssueListCell class] forCellReuseIdentifier:kTeamIssueListCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - tableView things

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamIssueListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kTeamIssueListCellID forIndexPath:indexPath];
    TeamIssueList *list = self.objects[indexPath.row];
    
    [cell.titleLabel setText:list.title];
    [cell.detailLabel setText:list.listDescription.length? list.listDescription : @"暂无描述"];
    [cell.countLabel setText:[NSString stringWithFormat:@"%d/%d",list.openedIssueCount,list.allIssueCount]];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamIssueList *issueList = self.objects[indexPath.row];
    
    self.label.font = [UIFont systemFontOfSize:13];
    self.label.text = issueList.listDescription.length? issueList.listDescription : @"暂无描述";
    
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
    
    return height + 45;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TeamIssueList *list = self.objects[indexPath.row];
    TeamIssueController * issueVc = [[TeamIssueController alloc] initWithTeamID:_teamID projectID:_projectID userID:[Config getOwnID]
                                                                         source:_source andCatalogID:list.teamIssueID];
    
    [self.navigationController pushViewController:issueVc animated:YES];
}


@end
