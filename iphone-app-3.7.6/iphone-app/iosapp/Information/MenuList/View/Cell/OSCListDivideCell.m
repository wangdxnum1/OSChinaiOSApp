//
//  OSCListDivideCell.m
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCListDivideCell.h"

@interface OSCListDivideCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *contentImageViewLeft;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageViewCenter;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageViewRight;

@property (weak, nonatomic) IBOutlet UILabel *cateoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLable;
@end

@implementation OSCListDivideCell

#pragma mark - 解固方法
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _commentCountLable.layer.masksToBounds = YES;
    _commentCountLable.layer.cornerRadius = 3;
}

+ (instancetype)returnListDivideCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath identifierStr:(NSString *)identifier{
    OSCListDivideCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    return cell;
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    
    
}

@end
