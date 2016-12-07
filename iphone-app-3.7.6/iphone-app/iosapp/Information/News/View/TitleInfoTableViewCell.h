//
//  TitleInfoTableViewCell.h
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"
#import "OSCInformationDetails.h"
@interface TitleInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *recommendTagIv;
@property (weak, nonatomic) IBOutlet UIImageView *propertyTagIv;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentCountIcon;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (nonatomic, strong) OSCBlogDetail *blogDetail;
@property (nonatomic, strong) OSCInformationDetails *newsDetail;
@end
