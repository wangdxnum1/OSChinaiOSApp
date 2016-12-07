//
//  TweetLikeNewCell.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetLikeNewCell.h"
#import "Utils.h"

@implementation TweetLikeNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_portraitIv setCornerRadius:16];
//    _portraitIv.userInteractionEnabled = YES;
//    _nameLabel.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
