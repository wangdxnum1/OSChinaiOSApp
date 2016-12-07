//
//  SettingsPage.m
//  iosapp
//
//  Created by chenhaoxiang on 3/5/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "SettingsPage.h"
#import "Utils.h"
#import "Config.h"
#import "AboutPage.h"
#import "OSLicensePage.h"
#import "FeedBackViewController.h"
#import "AppDelegate.h"
#import "NewLoginViewController.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <SDImageCache.h>

@interface SettingsPage () <UIAlertViewDelegate>

@end

@implementation SettingsPage

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.tableView.separatorColor = [UIColor separatorColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([Config getOwnID] == 0) {
        return 2;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 1;
        case 1: return 4;
        case 2: return 1;
            
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];

    NSArray *titles = @[
                        @[@"清除缓存", @"消息通知"],
                        @[@"应用评分", @"关于我们", @"开源许可", @"问题反馈"],
                        @[@"注销登录"],
                        ];
    cell.textLabel.text = titles[indexPath.section][indexPath.row];
    cell.contentView.backgroundColor = [UIColor cellsColor];
    cell.textLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要清除缓存的图片和文件？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];

        } else if (row == 1){
            
        }
    } else if (section == 1) {
        if (row == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/kai-yuan-zhong-guo/id524298520?mt=8"]];
        } else if (row == 1) {
            [self.navigationController pushViewController:[AboutPage new] animated:YES];
        } else if (row == 2) {
            [self.navigationController pushViewController:[OSLicensePage new] animated:YES];
        } else if (row == 3) {
            if ([Config getOwnID] == 0) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
                NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
                [self presentViewController:loginVC animated:YES completion:nil];
                
                return;
            } else {
                FeedBackViewController *fbVc = [FeedBackViewController new];
                fbVc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:fbVc animated:YES];
            }
        }
    }else if (section == 2) {
        //新注册登录
        [Config clearNewProfile];
        
        [Config removeTeamInfo];
        [Config clearCookie];
        
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
            [cookieStorage deleteCookie:cookie];
        }
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
        HUD.label.text = @"注销成功";
        [HUD hideAnimated:YES afterDelay:0.5];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    } else {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }
}





@end
