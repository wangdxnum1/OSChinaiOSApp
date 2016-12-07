//
//  QuesAnsDetailHeadCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsDetailHeadCell.h"
#import "Utils.h"

@implementation QuesAnsDetailHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [(UIScrollView *)[[_contentWebView subviews] objectAtIndex:0] setBounces:NO];
    [(UIScrollView *)[[_contentWebView subviews] objectAtIndex:0] setScrollEnabled:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setQuestioinDetail:(OSCQuestion *)questioinDetail
{
    _titleLabel.text = questioinDetail.title;
    _tagLabel.attributedText = [self setTagAttributedString:questioinDetail.tags];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", questioinDetail.author, [[NSDate dateFromString:questioinDetail.pubDate] timeAgoSinceNow]];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)questioinDetail.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)questioinDetail.commentCount];
}

- (NSAttributedString *)setTagAttributedString:(NSArray *)array
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    __block NSUInteger stringLength = 0;
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", obj]]];
        
        [attributedString addAttributes:@{
                                          NSBackgroundColorAttributeName : [UIColor colorWithHex:0xf6f6f6],
                                          NSForegroundColorAttributeName : [UIColor newAssistTextColor],
                                          NSFontAttributeName            : [UIFont systemFontOfSize:12],
                                          }
                                  range:NSMakeRange(stringLength, obj.length+2)];
        
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        stringLength += obj.length + 3;
        
    }];
    
    return attributedString;
}

@end
