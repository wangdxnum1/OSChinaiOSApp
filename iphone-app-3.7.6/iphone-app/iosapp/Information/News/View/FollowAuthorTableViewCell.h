//
//  FollowAuthorTableViewCell.h
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"

@interface FollowAuthorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *portraitIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (nonatomic, strong) OSCBlogDetail *blogDetail;

@end
