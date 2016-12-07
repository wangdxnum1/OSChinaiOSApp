//
//  OSCSwipableCell.m
//  iosapp
//
//  Created by 李萍 on 2016/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSwipableCell.h"
//
//#import "TweetTableViewController.h"

@interface OSCSwipableCell () //<TweetTableViewControllerDelegate>

@property (nonatomic, strong) UIViewController *subViewController;

@end

@implementation OSCSwipableCell

+ (instancetype)returnReuseSwipableTweetCollectionViewCell:(UICollectionView* )curCollectionView
                                                identifier:(NSString* )identifierString
                                                 indexPath:(NSIndexPath* )indexPath
                                         subViewController:(UIViewController *)subViewController
{
    OSCSwipableCell *cell = [curCollectionView dequeueReusableCellWithReuseIdentifier:identifierString forIndexPath:indexPath];
    
    cell.subViewController = subViewController;
    cell.subViewController.view.frame = cell.contentView.bounds;
    [cell.contentView addSubview:cell.subViewController.view];
    
    return cell;
}


//#pragma mark - OSCSwipableCellDelegate
//- (void)SwipableListCollectionViewCell:(OSCSwipableCell *)clickCell
//                     didClickTableView:(__kindof UITableView* )tableView
//                    pushViewController:(UIViewController* )pushController
//{
////    if ([_delegate respondsToSelector:@selector(SwipableListCollectionViewCell:didClickTableViewCell:pushViewController:)]) {
////        [_delegate SwipableListCollectionViewCell:self didClickTableViewCell:tableViewCell pushViewController:pushController];
////    }
//}

//- (void)clickTweetCell:(TweetTableViewController *)tweetTableViewController pushViewController:(UIViewController *)pushViewController
//{
//    [_delegate SwipableListCollectionViewCell:self didClickTableView:tweetTableViewController.tableView pushViewController:pushViewController];
//}

@end
