//
//  FollowAuthorTableViewCell.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "FollowAuthorTableViewCell.h"
//#import "Config.h"
#import "Utils.h"

@implementation FollowAuthorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _followBtn.layer.contentsScale = [UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setBlogDetail:(OSCBlogDetail *)blogDetail
{
    [_portraitIv loadPortrait:[NSURL URLWithString:blogDetail.authorPortrait]];
    _nameLabel.text = blogDetail.author;
    
    _pubTimeLabel.text = [NSString stringWithFormat:@"发表于%@", [[NSDate dateFromString:blogDetail.pubDate] timeAgoSinceNow]];
    switch (blogDetail.authorRelation) {
        case 1://双方互为粉丝
        case 2://你单方面关注他
            [_followBtn setTitle:@"已关注" forState:UIControlStateNormal];
            break;
        case 3://他单方面关注我
		case 4: //互不关注
			[_followBtn setTitle:@"关注" forState:UIControlStateNormal];
			break;
        default:
            break;
    }
}

@end
