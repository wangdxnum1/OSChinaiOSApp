//
//  RandomMessageCell.h
//  iosapp
//
//  Created by ChanAetern on 1/21/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCRandomMessageItem;

@interface RandomMessageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *commentCount;
@property (nonatomic, strong) UILabel *timeLabel;

//- (void)setContentWithMessage:(OSCRandomMessage *)message;

- (void)setContentWithMessage:(OSCRandomMessageItem *)message;

@end
