//
//  OSCSwipableCell.h
//  iosapp
//
//  Created by 李萍 on 2016/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCSwipableCell;
@protocol OSCSwipableCellDelegate <NSObject>

//- (void)SwipableListCollectionViewCell:(OSCSwipableCell *)clickCell
//                     didClickTableView:(__kindof UITableView* )tableView
//                    pushViewController:(UIViewController* )pushController;

@end

@interface OSCSwipableCell : UICollectionViewCell

+ (instancetype)returnReuseSwipableTweetCollectionViewCell:(UICollectionView* )curCollectionView
                                                identifier:(NSString* )identifierString
                                                 indexPath:(NSIndexPath* )indexPath
                                         subViewController:(UIViewController *)subViewController;

@property (nonatomic, weak) id<OSCSwipableCellDelegate> delegate;

@end
