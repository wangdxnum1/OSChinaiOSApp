//
//  ActivityDetailCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityDetailCell.h"
#import "Utils.h"

@implementation ActivityDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor themeColor];
    
    _label.hidden = NO;
    _iconImageView.hidden = NO;
    
    _activityBodyView.hidden = YES;
    
    _activityBodyView.scrollView.bounces = NO;
    _activityBodyView.scrollView.scrollEnabled = NO;
    _activityBodyView.opaque = NO;
    _activityBodyView.backgroundColor = [UIColor themeColor];
}

- (void)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"priceType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        
        _activityBodyView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_ticket"];
    } else if ([identifier isEqualToString:@"timeType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        
        _activityBodyView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_calendar"];
    } else if ([identifier isEqualToString:@"addressType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        
        _activityBodyView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_location"];
    } else if ([identifier isEqualToString:@"descType"]) {
        _label.hidden = YES;
        _iconImageView.hidden = YES;
        
        _activityBodyView.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - CONTENT

- (void)setActivity:(OSCActivities *)activity
{
    [self dequeueReusableCellWithIdentifier:_cellType];
    
    if ([_cellType isEqualToString:@"priceType"]) {
        _label.text = activity.costDesc;
        
    } else if ([_cellType isEqualToString:@"timeType"]) {
        _label.text = activity.startDate;
        
    } else if ([_cellType isEqualToString:@"addressType"]) {
        _label.text = activity.spot;
        
    }
}

@end
