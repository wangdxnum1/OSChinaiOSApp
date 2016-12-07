//
//  OSCListNomalCell.m
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCListNomalCell.h"
#import "OSCListItem.h"

@interface OSCListNomalCell ()
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *categoryLable;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLable;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@end

@implementation OSCListNomalCell

#pragma mark - 解固方法
- (void)awakeFromNib {
    [super awakeFromNib];

    _commentCountLable.layer.masksToBounds = YES;
    _commentCountLable.layer.cornerRadius = 3;
    
    _deleteBtn.hidden = YES;
}

+ (instancetype)returnListNomalCellWithTableView:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                   identifierStr:(NSString *)identifier
{
    OSCListNomalCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    return cell;
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    
}

@end
