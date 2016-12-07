//
//  MemberCell.h
//  iosapp
//
//  Created by chenhaoxiang on 3/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamMember;

@interface MemberCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel     *nameLabel;

- (void)setContentWithMember:(TeamMember *)member;

@end
