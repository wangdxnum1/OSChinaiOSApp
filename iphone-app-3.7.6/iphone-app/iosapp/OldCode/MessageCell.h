//
//  MessageCell.h
//  iosapp
//
//  Created by ChanAetern on 12/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCMessage;

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentCountLabel;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);
@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);

- (void)deleteObject:(id)sender;

@end
