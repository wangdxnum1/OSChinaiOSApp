//
//  TweetsDetailNewCell.m
//  iosapp
//
//  Created by Holden on 16/6/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetsDetailNewCell.h"

@implementation TweetsDetailNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _portraitIv.userInteractionEnabled = YES;
    _likeTagIv.userInteractionEnabled = YES;
    _commentTagIv.userInteractionEnabled = YES;
    [_portraitIv.layer setCornerRadius:22];
    [(UIScrollView *)[[_contentWebView subviews] objectAtIndex:0] setBounces:NO];
    [(UIScrollView *)[[_contentWebView subviews] objectAtIndex:0] setScrollEnabled:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
