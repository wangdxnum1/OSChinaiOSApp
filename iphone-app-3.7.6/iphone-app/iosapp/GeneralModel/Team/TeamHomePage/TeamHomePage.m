//
//  TeamHomePage.m
//  iosapp
//
//  Created by chenhaoxiang on 4/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamHomePage.h"
#import "TeamUserMainCell.h"
#import "Utils.h"
#import "Config.h"
#import "TeamAPI.h"
#import "TeamUser.h"
#import "TeamActivityViewController.h"
#import "TeamDiscussionViewController.h"
#import "WeeklyReportViewController.h"
#import "ProjectListViewController.h"


#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import "NSString+FontAwesome.h"

#import "SwipableViewController.h"
#import "TeamIssueController.h"

@interface TeamHomePage ()

@property (nonatomic, strong) TeamUser *user;
@property (nonatomic, assign) int teamID;

@end

@implementation TeamHomePage

- (instancetype)initWithTeamID:(int)teamID
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _teamID = teamID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -- selecteIssueType
-(void)selecteIssueType:(UIButton*)btn
{
    TeamIssueController *openedIssueVC = [[TeamIssueController alloc]initWithTeamID:_teamID userID:[Config getOwnID] andIssueState:IssueStateOpened];
    TeamIssueController *underwayIssueVC = [[TeamIssueController alloc]initWithTeamID:_teamID userID:[Config getOwnID] andIssueState:IssueStateUnderway];
    TeamIssueController *closedIssueVC = [[TeamIssueController alloc]initWithTeamID:_teamID userID:[Config getOwnID] andIssueState:IssueStateClosed];
    TeamIssueController *acceptedIssueVC = [[TeamIssueController alloc]initWithTeamID:_teamID userID:[Config getOwnID] andIssueState:IssueStateAccepted];
    
    SwipableViewController *myIssueVC = [[SwipableViewController alloc]
                                              initWithTitle:@"我的任务"
                                              andSubTitles:@[@"待办中", @"进行中", @"已完成", @"已验收"]
                                              andControllers:@[openedIssueVC,underwayIssueVC,closedIssueVC,acceptedIssueVC]];
    [myIssueVC scrollToViewAtIndex:btn.tag];
    [self.navigationController pushViewController:myIssueVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 250 : 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TeamUserMainCell *cell = [TeamUserMainCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (_user) {
            [cell setContentWithUser:_user withTarget:self];
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [UITableViewCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:18];

        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:
                                                      @[[NSString fontAwesomeIconStringForEnum:FAHome],[NSString fontAwesomeIconStringForEnum:FAInbox],[NSString fontAwesomeIconStringForEnum:FAComments],[NSString fontAwesomeIconStringForEnum:FAFileTextO]][indexPath.row]
                                                                                            attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0x15A230]
                                      }];
        [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:
                                                 @[@"   团队动态",@"   团队项目",@"   团队讨论",@"   团队周报"][indexPath.row]
                      attributes:@{                                                                                                                                         NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                                                                                                                                                                         NSForegroundColorAttributeName: [UIColor grayColor]              }]];
        cell.textLabel.attributedText = attributedTitle;

        

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 5.f;
        cell.backgroundColor = UIColor.clearColor;
        
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGRect bounds = CGRectInset(cell.bounds, 10, 0);
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        
        layer.fillColor = [UIColor teamButtonColor].CGColor;
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
        
        cell.indentationLevel = 1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {return;}
    
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[[TeamActivityViewController alloc] initWithTeamID:_teamID] animated:YES];
    } else if (indexPath.row == 1) {
        [self.navigationController pushViewController:[[ProjectListViewController alloc]initWithTeamId:_teamID] animated:YES];
    } else if (indexPath.row == 2) {
        [self.navigationController pushViewController:[[TeamDiscussionViewController alloc] initWithTeamID:_teamID] animated:YES];
    } else if (indexPath.row == 3) {
        [self.navigationController pushViewController:[[WeeklyReportViewController alloc] initWithTeamID:_teamID] animated:YES];
    }
}


#pragma mark - 更新数据

- (void)refresh
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_USER_ISSUE_INFORMATION]
      parameters:@{
                   @"teamid": @(_teamID),
                   @"uid": @([Config getOwnID])
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _user = [[TeamUser alloc] initWithXML:responseObject.rootElement];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}


@end
