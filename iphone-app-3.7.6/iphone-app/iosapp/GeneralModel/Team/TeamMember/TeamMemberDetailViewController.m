//
//  TeamMemberDetailViewController.m
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamMemberDetailViewController.h"
#import "TeamAPI.h"
#import "Config.h"
#import "TeamMember.h"
#import "TeamActivity.h"
#import "MemberDetailCell.h"
#import "TeamActivityCell.h"
#import "TeamActivityDetailViewController.h"

static NSString * const kUserActivityCellID = @"userActivityCell";
static NSString * const kMemberDetailCellID = @"memberDetailCell";

@interface TeamMemberDetailViewController ()

@property (nonatomic)int teamId;
@property (nonatomic)int uId;
@property (nonatomic,strong)TeamMember *member;

@end


@implementation TeamMemberDetailViewController

//teamid 团队id
//pageIndex 页数
//pageSize 每页条数
//type （是否需要区分动态的类别，如：所有/动弹/git/分享/讨论/周报，"all","tweet","git","share","discuss","report"）
//uid 要查询动态的用户id
- (instancetype)initWithUId:(int)uId
{
    if (self = [super init]) {
        self.generateURL = ^NSString * (NSUInteger page) {
            NSString *url = [NSString stringWithFormat:@"%@%@?teamid=%d&uid=%d&pageIndex=%lu&pageSize=20&type=all", TEAM_PREFIX, TEAM_ACTIVE_LIST, [Config teamID], uId,(unsigned long)page];
            return url;
        };
        self.teamId = [Config teamID];
        self.uId = uId;
        self.objClass = [TeamActivity class];
        
        __weak typeof(self) weakSelf = self;
        self.anotherNetWorking = ^{
            [weakSelf getMemberDetailInfo];
        };
    }
    
    return self;
}
- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"actives"] childrenWithTag:@"active"];
}

-(void)getMemberDetailInfo
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSString *url = [NSString stringWithFormat:@"%@%@?uid=%d&teamid=%d", TEAM_PREFIX, TEAM_USER_INFORMATION,_uId,_teamId];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *memberDetailsXML = [responseObject.rootElement firstChildWithTag:@"member"];
             _member = [[TeamMember alloc] initWithXML:memberDetailsXML];
//             dispatch_async(dispatch_get_main_queue(), ^{
                 if(self.tableView){
                     [self.tableView reloadData];
                 }
//             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"用户主页";
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerClass:[TeamActivityCell class] forCellReuseIdentifier:kUserActivityCellID];
    [self.tableView registerClass:[MemberDetailCell class] forCellReuseIdentifier:kMemberDetailCellID];
    
//    [self getMemberDetailInfo];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 35;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return @"最近动态";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 113;
    } else {
        TeamActivity *activity = self.objects[indexPath.row];
        self.label.attributedText = activity.attributedTitle;
        CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 60, MAXFLOAT)].height;
        return height + 63;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0? 1 : self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        MemberDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberDetailCellID forIndexPath:indexPath];
        if (_member) {
            [cell setContentWithTeamMember:_member];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        TeamActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserActivityCellID forIndexPath:indexPath];
        TeamActivity *activity = self.objects[indexPath.row];
        [cell setContentWithActivity:activity];
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != 0) {
        TeamActivity *activity = self.objects[indexPath.row];
        TeamActivityDetailViewController *detailVC = [[TeamActivityDetailViewController alloc] initWithActivity:activity andTeamID:_teamId];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
