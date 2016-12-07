//
//  TitleInfoTableViewCell.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TitleInfoTableViewCell.h"

@implementation TitleInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (void)setBlogDetail:(OSCBlogDetail *)blogDetail
{
    if (blogDetail.recommend) {//推荐
        _recommendTagIv.image = [UIImage imageNamed:@"ic_label_recommend"];
        _propertyTagIv.hidden = NO;
        if (blogDetail.original) {//原
            _propertyTagIv.image = [UIImage imageNamed:@"ic_label_originate"];
        } else {//转
            _propertyTagIv.image = [UIImage imageNamed:@"ic_label_reprint"];
        }
    } else {
        _propertyTagIv.hidden = YES;
        if (blogDetail.original) {//原
            _recommendTagIv.image = [UIImage imageNamed:@"ic_label_originate"];
        } else {//转
            _recommendTagIv.image = [UIImage imageNamed:@"ic_label_reprint"];
        }
    }
    
    _TitleLabel.text = blogDetail.title;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)blogDetail.commentCount];
}

- (void)setNewsDetail:(OSCInformationDetails *)newsDetail {
    _propertyTagIv.hidden = YES;
    _recommendTagIv.hidden = YES;
    
    _commentCountIcon.hidden = YES;
    _commentCountLabel.hidden = YES;
    
    _TitleLabel.text = newsDetail.title;
    _authorLabel.text = [NSString stringWithFormat:@"@%@  ", newsDetail.author];
    _timeLabel.text = [self timeComponentsSep:newsDetail.pubDate];
}

- (NSString *)timeComponentsSep:(NSString *)pubdate
{
    NSString *string = [pubdate componentsSeparatedByString:@" "][0];
    
    string = [string stringByReplacingCharactersInRange:NSMakeRange(7, 1) withString:@"月"];
    string = [string stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"年"];
    
    return [NSString stringWithFormat:@"发布于 %@日", string];
}

@end
