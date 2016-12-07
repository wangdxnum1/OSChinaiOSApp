//
//  TweetCommentNewCell.h
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCommentItem.h"
@interface TweetCommentNewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *portraitIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *interalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentTagIv;

@property (nonatomic, strong)OSCCommentItem *commentModel;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);
@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);

- (void)copyText:(id)sender;
- (void)deleteObject:(id)sender;
@end
