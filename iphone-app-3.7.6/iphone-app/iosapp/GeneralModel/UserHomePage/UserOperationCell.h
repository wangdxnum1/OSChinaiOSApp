//
//  UserOperationCell.h
//  iosapp
//
//  Created by ChanAetern on 2/7/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserOperationCell : UITableViewCell

@property (nonatomic, strong) UILabel  *loginTimeLabel;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *blogsButton;
@property (nonatomic, strong) UIButton *informationButton;

- (void)setFollowButtonByRelationship:(int)relationship;

@end
