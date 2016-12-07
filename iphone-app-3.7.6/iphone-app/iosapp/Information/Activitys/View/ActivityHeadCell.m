//
//  ActivityHeadCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityHeadCell.h"
#import "Utils.h"

@interface ActivityHeadCell ()

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *catalogLabel;
@property (weak, nonatomic) IBOutlet UILabel *applyLabel;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@end

@implementation ActivityHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    _typeButton.layer.borderWidth = 1.0;
    _typeButton.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
    [_typeButton setTitleColor:[UIColor colorWithHex:0xffffff] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActivity:(OSCActivities *)activity
{
    [_activityImageView loadPortrait:[NSURL URLWithString:activity.img]];
    _titleLable.text = activity.title;
    _authorLabel.text = [NSString stringWithFormat:@"发起人：%@", activity.author];
    _catalogLabel.text = [self categoryString:activity];
    _applyLabel.text = [NSString stringWithFormat:@"%ld人参与", activity.applyCount];
    
    [self typeActivityStatus:activity];
}

/* 活动状态按钮 */
- (void)typeActivityStatus:(OSCActivities *)activity
{
    if (activity.status == ActivityStatusEnd) {
        _typeButton.hidden = YES;
    } else if (activity.status == ActivityStatusHaveInHand) {
        [_typeButton setTitle:@"正在报名" forState:UIControlStateNormal];
    } else if (activity.status == ActivityStatusClose) {
        _typeButton.hidden = YES;
    }
}
/* 活动类型 */
- (NSString *)categoryString:(OSCActivities *)activity
{
    NSString *string = @"";
    if (activity.type == ActivityTypeOSChinaMeeting) {
        string = @"源创会";
    } else if (activity.type == ActivityTypeTechnical) {
        string = @"技术交流";
    } else if (activity.type == ActivityTypeOther) {
        string = @"其他";
    } else if (activity.type == ActivityTypeBelow) {
        string = @"站外活动";
    }
    
    return [NSString stringWithFormat:@"类型：%@", string];
}

@end
