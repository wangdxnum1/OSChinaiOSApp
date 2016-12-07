//
//  WeeklyReportDetailViewController.m
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "WeeklyReportDetailViewController.h"
#import "TimeLineNodeCell.h"
#import "TeamAPI.h"
#import "TeamWeeklyReportDetail.h"
#import "TeamDetailContentCell.h"
#import "Utils.h"
#import "Config.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

static NSString * const kTimeLineNodeCellID = @"TimeLineNodeCell";

@interface WeeklyReportDetailViewController ()

@property (nonatomic, strong) TeamWeeklyReportDetail *detail;
@property (nonatomic, assign) int reportID;

@end

@implementation WeeklyReportDetailViewController

- (instancetype)initWithReportID:(int)reportID
{
    self = [super initWithObjectID:reportID andType:TeamReplyTypeDiary];
    if (self) {
        _reportID = reportID;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor themeColor];
    self.navigationItem.title = @"周报内容";
    [self.tableView registerClass:[TimeLineNodeCell class] forCellReuseIdentifier:kTimeLineNodeCellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", TEAM_PREFIX, TEAM_DIARY_DETAIL]
      parameters:@{
                   @"teamid":  @([Config teamID]),
                   @"diaryid": @(_reportID),
                   }
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             _detail = [[TeamWeeklyReportDetail alloc] initWithXML:[responseObject.rootElement firstChildWithTag:@"diary"]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

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
        return _detail? _detail.days + 1 : 0;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont systemFontOfSize:15];
    
    if (indexPath.section == 0) {
        if (row == 0) {
            label.attributedText = _detail.summary;
            CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 16, MAXFLOAT)].height;
            
            return height + 62;
        } else {
            NSAttributedString *attributedString = _detail.details[row-1][1];
            
            label.attributedText = attributedString;
            CGFloat height = [label sizeThatFits:CGSizeMake(tableView.bounds.size.width - 99, MAXFLOAT)].height;
            
            return height + 18;
        }
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (indexPath.section == 0) {
        if (row == 0 && _detail) {
            TeamDetailContentCell *cell = [TeamDetailContentCell new];
            [cell setContentWithReportDetail:_detail];
            
            return cell;
        } else {                //if (row < _detail.days - 1) {
            row -= 1;
            TimeLineNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kTimeLineNodeCellID forIndexPath:indexPath];
            
            [cell setContentWithString:_detail.details[row][1]];
            cell.dayLabel.text = _detail.details[row][0];
            
            cell.upperLine.hidden = row == 0;
            cell.underLine.hidden = row == _detail.days-1;
            
            return cell;
        }
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
                    @"teamid": @([Config teamID]),
                    @"uid": @([Config getOwnID]),
                    @"type": @(118),
                    @"tweetid": @(_reportID),
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
