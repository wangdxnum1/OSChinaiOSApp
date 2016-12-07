//
//  MessageBubbleCell.h
//  iosapp
//
//  Created by ChanAetern on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCComment;

static NSString * const kMessageBubbleOthers = @"MessageBubbleOthers";
static NSString * const kMessageBubbleMe     = @"MessageBubbleMe";

@interface MessageBubbleCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);
@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);

- (void)setContent:(NSString *)content andPortrait:(NSURL *)portraitURL;

- (void)deleteObject:(id)sender;
- (void)copyText:(id)sender;

@end
