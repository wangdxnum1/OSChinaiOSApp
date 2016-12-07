//
//  TeamActivityDetailViewController.m
//  iosapp
//
//  Created by Holden on 15/5/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TeamActivityDetailViewController.h"
#import "TeamAPI.h"
#import "Utils.h"
#import "Config.h"
#import "TeamActivity.h"
#import "TeamDetailContentCell.h"
#import "TeamReply.h"
#import "TeamReplyCell.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

static NSString * const kTeamReplyCellID = @"TeamReplyCell";

@interface TeamActivityDetailViewController ()

@property (nonatomic, assign) int teamID;
@property (nonatomic, strong) TeamActivity *activity;

@end

@implementation TeamActivityDetailViewController

- (instancetype)initWithActivity:(TeamActivity *)activity andTeamID:(int)teamID
{
    self = [super initWithObjectID:activity.activityID andType:TeamReplyTypeActivity];
    if (self) {
        _activity = activity;
        _teamID = teamID;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"动态详情";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (indexPath.section == 0) {
        label.attributedText = _activity.attributedDetail;
        
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
        
        return height + 62;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return [super tableView:tableView titleForHeaderInSection:section];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TeamDetailContentCell *cell = [TeamDetailContentCell new];
        [cell setContentWithActivity:_activity];
        
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma 发表评论

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_TWEET_REPLY]
       parameters:@{
                    @"teamid": @(_teamID),
                    @"uid": @([Config getOwnID]),
                    @"type": @(_activity.type),
                    @"tweetid": @(_activity.activityID),
                    @"content": [Utils convertRichTextToRawText:self.editingBar.editView]
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              HUD.mode = MBProgressHUDModeCustomView;
             
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                 
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.label.text = @"评论发表成功";
                 
                  [self.tableView setContentOffset:CGPointZero animated:NO];
                  [self fetchRepliesOnPage:0];
              } else {
//                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.label.text = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              
              [HUD hideAnimated:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.detailsLabel.text = error.localizedFailureReason;
             
              [HUD hideAnimated:YES afterDelay:1];
          }];
}






@end
