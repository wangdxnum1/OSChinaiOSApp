//
//  OSCMessageCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCMessageCell;
@protocol OSCMessageCellDelegate <NSObject>

- (void)messageCellDidClickUserPortrait:(OSCMessageCell* )cell;

@optional
- (void)messageCellDidClickDelete:(OSCMessageCell* )cell;

- (void)messageCellDidClickSetTop:(OSCMessageCell* )cell;

@end

@class MessageItem;

@interface OSCMessageCell : UITableViewCell

+ (instancetype)returnReuseMessageCellWithTableView:(UITableView* )tableView
                                          indexPath:(NSIndexPath* )indexPath
                                         identifier:(NSString* )reuseIdentifier;

@property (nonatomic,weak) id<OSCMessageCellDelegate> delegate;

@property (nonatomic,strong) MessageItem* messageItem;

@property (nonatomic,assign,getter=isOpenSlidingOperation) BOOL openSlidingOperation;///<是否开启滑动操作 默认是NO

- (void)resetTheLocation;

@end
