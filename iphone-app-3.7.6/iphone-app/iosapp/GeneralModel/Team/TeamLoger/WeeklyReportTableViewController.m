//
//  WeeklyReportTableViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportTableViewController.h"
#import "TeamAPI.h"
#import "TeamWeeklyReport.h"
#import "WeeklyReportCell.h"
#import "TeamWeeklyReportDetail.h"
#import "WeeklyReportDetailViewController.h"

static NSString * const kWeeklyReportCellID = @"WeeklyReportCell";

@interface WeeklyReportTableViewController ()

@property (nonatomic, assign) int teamID;

@end

@implementation WeeklyReportTableViewController

- (instancetype)initWithTeamID:(int)teamID year:(NSInteger)year andWeek:(NSInteger)week
{
    if (self = [super init]) {
        _teamID = teamID;
        _year = year;
        _week = week;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?teamid=%d&year=%ld&week=%ld&pageIndex=%lu", TEAM_PREFIX, TEAM_DIARY_LIST, teamID, (long)year, (long)week, (unsigned long)page];
        };
        
        self.objClass = [TeamWeeklyReport class];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[WeeklyReportCell class] forCellReuseIdentifier:kWeeklyReportCellID];
    
    self.lastCell.emptyMessage = @"本周没有人提交周报";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"diaries"] childrenWithTag:@"diary"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamWeeklyReport *weeklyReport = self.objects[indexPath.row];
    
    self.label.attributedText = weeklyReport.attributedTitle;
    
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
    
    return height + 63;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeeklyReportCell *cell = [tableView dequeueReusableCellWithIdentifier:kWeeklyReportCellID forIndexPath:indexPath];
    TeamWeeklyReport *weeklyReport = self.objects[indexPath.row];
    
    [cell setContentWithWeeklyReport:weeklyReport];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TeamWeeklyReport *report = self.objects[indexPath.row];
    [self.navigationController pushViewController:[[WeeklyReportDetailViewController alloc] initWithReportID:report.reportID] animated:YES];
}


@end
