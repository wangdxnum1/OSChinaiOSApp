//
//  PresentMembersViewController.m
//  iosapp
//
//  Created by 李萍 on 15/3/6.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "PresentMembersViewController.h"
#import "OSCEventPersonInfo.h"
#import "OSCAPI.h"
#import "PersonCell.h"
#import "OSCUserHomePageController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

static NSString * const kPersonCellID = @"PersonCell";

@interface PresentMembersViewController ()

@end

@implementation PresentMembersViewController

- (instancetype)initWithEventID:(int64_t)eventID
{
    self = [super init];
    if (!self) {return nil;}
    
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@?event_id=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_EVENT_ATTEND_USER, eventID, (unsigned long)page, OSCAPI_SUFFIX];
    };
    
    self.objClass = [OSCEventPersonInfo class];
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"applies"] childrenWithTag:@"apply"];
}


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PersonCell class] forCellReuseIdentifier:kPersonCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCEventPersonInfo *person = self.objects[indexPath.row];
    PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonCellID forIndexPath:indexPath];
    
    [cell.portrait loadPortrait:person.portraitURL];
    cell.nameLabel.text = person.userName;
    cell.infoLabel.text = [NSString stringWithFormat:@"%@ %@",person.company, person.job];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCEventPersonInfo *person = self.objects[indexPath.row];
    self.label.text = person.userName;
    self.label.font = [UIFont systemFontOfSize:16];
    CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
    
    self.label.text = [NSString stringWithFormat:@"%@ %@",person.company, person.job];
    self.label.font = [UIFont systemFontOfSize:12];
    CGSize infoLabelSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
    return nameSize.height + infoLabelSize.height + 21;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCEventPersonInfo *person = self.objects[indexPath.row];
    
    if (person.userID > 0) {
        
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:person.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}
@end
