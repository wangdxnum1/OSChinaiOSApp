//
//  QuestCommentHeadDetailCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuestCommentHeadDetailCell.h"
#import "Utils.h"

@implementation QuestCommentHeadDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCommentDetail:(OSCNewComment *)commentDetail
{
    [_portraitView loadPortrait:[NSURL URLWithString:commentDetail.authorPortrait]];
    _nameLabel.text = commentDetail.author;
    _timeLabel.text = [[NSDate dateFromString:commentDetail.pubDate] timeAgoSinceNow];//[NSString stringWithFormat:@"%@(%@)", [[NSDate dateFromString:commentDetail.pubDate] timeAgoSinceNow], commentDetail.pubDate];
    
    [_downOrUpButton setTitle:[NSString stringWithFormat:@"%ld", (long)commentDetail.vote] forState:UIControlStateNormal];
    
    switch (commentDetail.voteState) {
        case 0://未操作
        {
            [_downOrUpButton setImage:[UIImage imageNamed:@"ic_vote"] forState:UIControlStateNormal];
            break;
        }
        case 1://已顶
        {
            [_downOrUpButton setImage:[UIImage imageNamed:@"ic_vote_up"] forState:UIControlStateNormal];
            break;
        }
        case 2://已踩
        {
            [_downOrUpButton setImage:[UIImage imageNamed:@"ic_vote_down"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

@end
