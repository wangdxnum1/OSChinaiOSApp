//
//  OSCDiscussCell.m
//  iosapp
//
//  Created by Graphic-one on 16/9/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCDiscussCell.h"
#import "OSCDiscuss.h"
#import "UIImageView+CornerRadius.h"
#import "ImageDownloadHandle.h"
#import "UIColor+Util.h"
#import "NSDate+Util.h"

#define GRAY_COLOR [UIColor colorWithHex:0x9d9d9d]
#define HIGHLIGHTED_COLOR [UIColor colorWithHex:0x24cf5f]

@interface OSCDiscussCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end

@implementation OSCDiscussCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_userPortraitImageView zy_cornerRadiusRoundingRect];
}

+ (instancetype)returnReuseDiscussCellWithTableView:(UITableView *)tableView
                                          indexPath:(NSIndexPath *)indexPath
                                         identifier:(NSString *)reuseIdentifier
{
    OSCDiscussCell* discussCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    return discussCell;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.contentView.backgroundColor = [UIColor newCellColor];
        self.backgroundColor = [UIColor themeColor];
        self.titleLabel.textColor = [UIColor newTitleColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    }
    return self;
}

#pragma mark --- setting model
- (void)setDiscuss:(OSCDiscuss *)discuss{
    _discuss = discuss;
    
    UIImage* portraitImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:discuss.author.portrait];
    if (!portraitImage) {
        [ImageDownloadHandle downloadImageWithUrlString:discuss.author.portrait SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_userPortraitImageView setImage:image];
            });
        }];
    }else{
        [_userPortraitImageView setImage:portraitImage];
    }

    _userNameLabel.text = discuss.author.name;
    
    NSMutableAttributedString* mutableAtt = [[NSMutableAttributedString alloc]init];
    
    switch (discuss.origin.type) {
        case OSCDiscusOriginTypeLineNews:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了新闻“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeSoftWare:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了软件“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeForum:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"回复了问答“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeBlog:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了博客“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeTranslation:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了翻译文章“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeActivity:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了活动“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeInfo:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了资讯“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        case OSCDiscusOriginTypeTweet:
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"评论了动弹“" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:discuss.origin.desc attributes:@{NSForegroundColorAttributeName : HIGHLIGHTED_COLOR}]];
            [mutableAtt appendAttributedString:[[NSAttributedString alloc]initWithString:@"”：" attributes:@{NSForegroundColorAttributeName : GRAY_COLOR}]];
            break;
            
        default:
            break;
    }
    _titleLabel.attributedText = mutableAtt;
    
    _commentLabel.text = discuss.content;
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:discuss.pubDate] timeAgoSinceNow]]];
    _timeLabel.attributedText = att;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld",discuss.commentCount];
}
/** OSCDiscusOriginType_ENUM
 
 *  OSCDiscusOriginTypeLineNews = 0,
 *  OSCDiscusOriginTypeSoftWare = 1,
 *  OSCDiscusOriginTypeForum = 2,
 *  OSCDiscusOriginTypeBlog = 3,
 *  OSCDiscusOriginTypeTranslation = 4,
 *  OSCDiscusOriginTypeActivity = 5,
 *  OSCDiscusOriginTypeInfo = 6,
 *  OSCDiscusOriginTypeTweet = 100
 */


@end
