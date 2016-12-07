//
//  TweetsLikeListViewController.m
//  iosapp
//
//  Created by 李萍 on 15/4/3.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "TweetsLikeListViewController.h"
#import "OSCUser.h"
#import "TweetLikeUserCell.h"
#import "OSCUserHomePageController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

static NSString * const kTweetLikeUserCellID = @"TweetLikeUserCell";

@interface TweetsLikeListViewController ()

@end

@implementation TweetsLikeListViewController

- (instancetype)initWithtweetID:(int64_t)tweetID
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?tweetid=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_TWEET_LIKE_LIST, tweetID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCUser class];
    }
    
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"likeList"] childrenWithTag:@"user"];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    self.navigationItem.title = @"点赞列表";
    
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[TweetLikeUserCell class] forCellReuseIdentifier:kTweetLikeUserCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCUser *likesUser = self.objects[indexPath.row];
    TweetLikeUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetLikeUserCellID forIndexPath:indexPath];
    
    [cell.portrait loadPortrait:likesUser.portraitURL];
    cell.userNameLabel.text = likesUser.name;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCUser *likesUser = self.objects[indexPath.row];
    self.label.text = likesUser.name;
    self.label.font = [UIFont systemFontOfSize:16];
    CGSize nameSize = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
    
    return nameSize.height + 32;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCUser *likesUser = self.objects[indexPath.row];
    if (likesUser.userID > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:likesUser.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}


@end
