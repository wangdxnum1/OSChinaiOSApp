//
//  OSCListAdCell.m
//  iosapp
//
//  Created by Graphic-one on 16/10/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCListAdCell.h"
#import "OSCListItem.h"

@interface OSCListAdCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *adBannerImageView;

@property (weak, nonatomic) IBOutlet UILabel *adLabel;
@end

@implementation OSCListAdCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _adLabel.layer.masksToBounds = YES;
    _adLabel.layer.cornerRadius = 3;
}

+ (instancetype)returnListAdCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath identifierStr:(NSString *)identifier{
    OSCListAdCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    return cell;
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;

}

@end
