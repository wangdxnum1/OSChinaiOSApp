//
//  FavoritesCell.m
//  iosapp
//
//  Created by 李萍 on 2016/10/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "FavoritesCell.h"
#import "Utils.h"

@implementation FavoritesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFavorite:(OSCFavorites *)favorite
{
//    _typeArray = @[@"全部", @"软件", @"问答", @"博客", @"翻译", @"活动", @"资讯"];
    
    self.typeLable.layer.borderWidth = 1;
    self.typeLable.layer.borderColor = [UIColor colorWithHex:0xd2d2d2].CGColor;
    self.typeLable.layer.cornerRadius = 2;
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"         %@", favorite.title]];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:8];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [[NSString stringWithFormat:@"         %@", favorite.title] length])];
    
    [self.titleLabel setAttributedText:attributedString1];
    
    self.typeLable.text = @[@"全部", @"软件", @"问答", @"博客", @"翻译", @"活动", @"资讯"][favorite.type];
    self.userNameLabel.text = favorite.authorUser.name.length > 0 ? favorite.authorUser.name : @"暂无作者署名";
    self.timeLabel.text = [[NSDate dateFromString:favorite.favDate] timeAgoSinceNow];
    self.favCountLabel.text = [NSString stringWithFormat:@"%d", favorite.favCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%d", favorite.commentCount];
}

@end
