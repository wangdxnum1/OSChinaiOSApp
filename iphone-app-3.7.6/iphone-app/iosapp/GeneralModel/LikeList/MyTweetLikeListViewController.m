//
//  MyTweetLikeListViewController.m
//  iosapp
//
//  Created by 李萍 on 15/4/9.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MyTweetLikeListViewController.h"
#import "OSCMyTweetLikeList.h"
#import "MyTweetLikeListCell.h"

#import "OSCUserHomePageController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import <MBProgressHUD.h>

static NSString * const MyTweetLikeListCellID = @"MyTweetLikeListCell";

@interface MyTweetLikeListViewController ()

@end

@implementation MyTweetLikeListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?pageIndex=%ld", OSCAPI_PREFIX, OSCAPI_MY_TWEET_LIKE_LIST, (long)page];
        };
        
        self.objClass = [OSCMyTweetLikeList class];
    }
    return self;
}

- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"likeList"] childrenWithTag:@"mytweet"];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[MyTweetLikeListCell class] forCellReuseIdentifier:MyTweetLikeListCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

// 图片的高度计算方法参考 http://blog.cocoabit.com/blog/2013/10/31/guan-yu-uitableview-zhong-cell-zi-gua-ying-gao-du-de-wen-ti/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    OSCMyTweetLikeList *myTweetLikeList = self.objects[row];
    MyTweetLikeListCell *cell = [tableView dequeueReusableCellWithIdentifier:MyTweetLikeListCellID forIndexPath:indexPath];
    
    cell.authorTweetLabel.textColor = [UIColor titleColor];
    
    [cell setContentWithMyTweetLikeList:myTweetLikeList];
    
    cell.portrait.tag = row;
    [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushUserDetailsView:)]];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCMyTweetLikeList *myTweetLikeList = self.objects[indexPath.row];
    
    self.label.font = [UIFont boldSystemFontOfSize:14];
    [self.label setText:myTweetLikeList.name];
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
    
    [self.label setText:[NSString stringWithFormat:@"赞了我的动弹："]];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height + 5;
    
    [self.label setAttributedText:myTweetLikeList.authorAndBody];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height + 5;
    
    return height + 16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCMyTweetLikeList *myTweetLikeList = self.objects[indexPath.row];
    TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:myTweetLikeList.tweetId];
    [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
}

#pragma mark - 跳转到用户详情页

- (void)pushUserDetailsView:(UITapGestureRecognizer *)recognizer 
{
    OSCMyTweetLikeList *myTweetLikeList = self.objects[recognizer.view.tag];
    if (myTweetLikeList.userID > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:myTweetLikeList.userID];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}



@end
