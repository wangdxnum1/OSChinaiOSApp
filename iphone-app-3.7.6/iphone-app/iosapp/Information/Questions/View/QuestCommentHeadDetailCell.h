//
//  QuestCommentHeadDetailCell.h
//  iosapp
//
//  Created by 李萍 on 16/6/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCNewComment.h"

@interface QuestCommentHeadDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *portraitView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *downOrUpButton;

@property (nonatomic, strong) OSCNewComment *commentDetail;
@end
