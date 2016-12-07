//
//  PeopleTableViewController.m
//  iosapp
//
//  Created by ChanAetern on 1/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "PersonCell.h"
#import "OSCUser.h"
#import "OSCUserHomePageController.h"

#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kPersonCellID = @"PersonCell";

@implementation PeopleTableViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {return nil;}
    
    __weak PeopleTableViewController *weakSelf = self;
    self.generateURL = ^NSString * (NSUInteger page) {
        NSString *userName = [weakSelf.queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"%@%@?name=%@&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_SEARCH_USERS, userName, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCUser class];
    
    self.shouldFetchDataAfterLoaded = NO;
    
    return self;
}



- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"users"] childrenWithTag:@"user"];
}





#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PersonCell class] forCellReuseIdentifier:kPersonCellID];
    
    self.lastCell.emptyMessage = @"找不到和您的查询相符的用户";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCUser *user = self.objects[indexPath.row];
    PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonCellID forIndexPath:indexPath];
    
    [cell.portrait loadPortrait:user.portraitURL];
    cell.nameLabel.text = user.name;
    cell.infoLabel.text = user.location;
    cell.infoLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    OSCUser *friend = self.objects[indexPath.row];
//    self.label.text = friend.name;
//    self.label.font = [UIFont systemFontOfSize:16];
//    CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
//    
//    self.label.text = friend.location;
//    self.label.font = [UIFont systemFontOfSize:12];
//    CGSize infoLabelSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
//    
//    return nameSize.height + infoLabelSize.height + 21;
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCUser *user = self.objects[indexPath.row];
    if (user.userID > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:user.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

@end
