//
//  MemberDetailCell.h
//  iosapp
//
//  Created by Holden on 15/5/7.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamMember.h"
@interface MemberDetailCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portraitIv;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *eMailLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *phoneIconLabel;

- (void)setContentWithTeamMember:(TeamMember *)teamMember;
@end
