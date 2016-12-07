//
//  OSCActivityTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityTableViewCell.h"
#import "OSCActivities.h"
#import "OSCListItem.h"
#import "Utils.h"

#import <UIImageView+WebCache.h>

NSString* OSCActivityTableViewCell_IdentifierString = @"OSCActivityTableViewCellReuseIdenfitier";

@interface OSCActivityTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *activityStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityAreaLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;

@end

@implementation OSCActivityTableViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    _activityImageView.image = nil;
    _activityImageView.backgroundColor = [UIColor clearColor];
    _descLabel.textColor = [UIColor newTitleColor];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _descLabel.textColor = [UIColor newTitleColor];
    _activityStatusLabel.backgroundColor = [UIColor titleBarColor];
    _activityAreaLabel.backgroundColor = [UIColor titleBarColor];

//    switch (_viewModel.status) {
//        case ActivityStatusEnd:
//            _activityStatusLabel.layer.borderWidth = 0;
//            _activityStatusLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
//            break;
//        case ActivityStatusHaveInHand:
//            _activityStatusLabel.layer.borderWidth = 1.0;
//            _activityStatusLabel.layer.borderColor = [UIColor sectionButtonSelectedColor].CGColor;
//            break;
//        case ActivityStatusClose:
//            _activityStatusLabel.layer.borderWidth = 0;
//            _activityStatusLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
//            break;
//            
//        default:
//            break;
//    }
}

#pragma mark - public method 
+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString
{
    OSCActivityTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
                                                                     forIndexPath:indexPath];
    
    
    return cell;

}

#pragma mark - setting VM
-(void)setViewModel:(OSCActivities* )viewModel{
    _viewModel = viewModel;
    
    [_activityImageView loadPortrait:[NSURL URLWithString:viewModel.img]];
    _descLabel.text = viewModel.title;
    
    NSString *statusStr;
    switch (viewModel.status) {
        case ActivityStatusEnd:
            statusStr = @"  活动结束  ";
            [self setSelectedBorderWidth:NO];
            break;
        case ActivityStatusHaveInHand:
            [self setSelectedBorderWidth:YES];
            statusStr = @"  正在报名  ";
            break;
        case ActivityStatusClose:
            [self setSelectedBorderWidth:NO];
            statusStr = @"  报名截止  ";
            break;
            
        default:
            break;
    }
    _activityStatusLabel.text = statusStr;
    
    NSString *areaStr;
    switch (viewModel.type) {
        case ActivityTypeOSChinaMeeting:
            areaStr = @" 源创会 ";
            break;
        case ActivityTypeTechnical:
            areaStr = @" 技术交流 ";
            break;
        case ActivityTypeOther:
            areaStr = @" 其他 ";
            break;
        case ActivityTypeBelow:
            areaStr = @" 站外活动 ";
            break;
        default:
            break;
    }

    _activityAreaLabel.text = areaStr;
    _timeLabel.text = [viewModel.startDate substringToIndex:16];
    _peopleNumLabel.text = [NSString stringWithFormat:@"%ld人参与", (long)viewModel.applyCount];
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    if (listItem.image.href.count > 0) {
        [_activityImageView sd_setImageWithURL:[NSURL URLWithString:[listItem.image.href lastObject]] placeholderImage:[Utils createImageWithColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.6]] options:0];
    }else{
        _activityImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    }
    _descLabel.text = listItem.title;
    
    NSString *statusStr;
    switch (listItem.extra.eventStatus) {
        case ActivityStatusEnd:
            statusStr = @"  活动结束  ";
            [self setSelectedBorderWidth:NO];
            break;
        case ActivityStatusHaveInHand:
            [self setSelectedBorderWidth:YES];
            statusStr = @"  正在报名  ";
            break;
        case ActivityStatusClose:
            [self setSelectedBorderWidth:NO];
            statusStr = @"  报名截止  ";
            break;
            
        default:
            break;
    }
    _activityStatusLabel.text = statusStr;
    
    NSString *areaStr;
    switch (listItem.extra.eventType) {
        case ActivityTypeOSChinaMeeting:
            areaStr = @" 源创会 ";
            break;
        case ActivityTypeTechnical:
            areaStr = @" 技术交流 ";
            break;
        case ActivityTypeOther:
            areaStr = @" 其他 ";
            break;
        case ActivityTypeBelow:
            areaStr = @" 站外活动 ";
            break;
        default:
            break;
    }
    
    _activityAreaLabel.text = areaStr;
    _timeLabel.text = [listItem.extra.eventStartDate substringToIndex:16];
    _peopleNumLabel.text = [NSString stringWithFormat:@"%ld人参与", (long)listItem.extra.eventApplyCount];
}

- (void)setSelectedBorderWidth:(BOOL)isSelected
{
    if (isSelected) {
        _activityStatusLabel.layer.borderWidth = 1.0;
        _activityStatusLabel.layer.borderColor = [UIColor newSectionButtonSelectedColor].CGColor;
        _activityStatusLabel.textColor = [UIColor newSectionButtonSelectedColor];
    } else {
        _activityStatusLabel.layer.borderWidth = 0;
        _activityStatusLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    }
}

- (void)setCompleteRead{
    _descLabel.textColor = [UIColor lightGrayColor];
}

@end
