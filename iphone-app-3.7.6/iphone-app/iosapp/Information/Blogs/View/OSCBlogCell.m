//
//  OSCBlogCell.m
//  iosapp
//
//  Created by 李萍 on 2016/11/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCBlogCell.h"
#import "Utils.h"
#import "OSCListItem.h"

#import <YYKit.h>

@implementation OSCBlogCell
{
    UILabel *titleLabel;
    YYLabel *descLabel;
    
    YYLabel *nameLabel;
    YYLabel *timeLabel;
    
    UIImageView *viewIcon;
    YYLabel *viewCountLabel;
    UIImageView *commentIcon;
    YYLabel *commentCountLabel;
    UIView *bottomLine;
    
    CGFloat rowHeight;
}

+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString
{
    OSCBlogCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
                                                                    forIndexPath:indexPath];
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addCustomViews];
    }
    return self;
}

- (void)addCustomViews
{
    titleLabel = [UILabel new];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textColor = [UIColor newTitleColor];
    titleLabel.font = [UIFont systemFontOfSize:blogsCell_titleLB_Font_Size];
    [self.contentView addSubview:titleLabel];
    
    descLabel = [YYLabel new];
    descLabel.numberOfLines = 2;
    descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    descLabel.textColor = [UIColor newSecondTextColor];
    descLabel.font = [UIFont systemFontOfSize:blogsCell_descLB_Font_Size];
    [self.contentView addSubview:descLabel];
    
    nameLabel = [YYLabel new];
    nameLabel.textColor = [UIColor newAssistTextColor];
    nameLabel.font = [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size];
    [self.contentView addSubview:nameLabel];
    
    timeLabel = [YYLabel new];
    timeLabel.textColor = [UIColor newAssistTextColor];
    timeLabel.font = [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size];
    [self.contentView addSubview:timeLabel];
    
    viewCountLabel = [YYLabel new];
    viewCountLabel.textColor = [UIColor newAssistTextColor];
    viewCountLabel.font = [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size];
    [self.contentView addSubview:viewCountLabel];
    
    viewIcon = [UIImageView new];
    viewIcon.contentMode = UIViewContentModeScaleAspectFit;
    viewIcon.image = [UIImage imageNamed:@"ic_view"];
    [self.contentView addSubview:viewIcon];
    
    commentIcon = [UIImageView new];
    commentIcon.contentMode = UIViewContentModeScaleAspectFit;
    commentIcon.image = [UIImage imageNamed:@"ic_comment"];
    [self.contentView addSubview:commentIcon];
    
    commentCountLabel = [YYLabel new];
    commentCountLabel.textColor = [UIColor newAssistTextColor];
    commentCountLabel.font = [UIFont systemFontOfSize:blogsCell_infoLB_Font_Size];
    [self.contentView addSubview:commentCountLabel];
    
    bottomLine = [[UIView alloc] initWithFrame:CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1)];
    bottomLine.backgroundColor = [[UIColor colorWithHex:0xC8C7CC] colorWithAlphaComponent:0.7];
    [self.contentView addSubview:bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    titleLabel.frame = _listItem.blogLayoutInfo.titleLbFrame;
    descLabel.frame = _listItem.blogLayoutInfo.descLbFrame;
    
    nameLabel.frame = _listItem.blogLayoutInfo.userNameLbFrame;
    timeLabel.frame = _listItem.blogLayoutInfo.timeLbFrame;
    
    viewIcon.frame = _listItem.blogLayoutInfo.viewCountImgFrame;
    viewCountLabel.frame = _listItem.blogLayoutInfo.viewCountLbFrame;
    commentIcon.frame = _listItem.blogLayoutInfo.commentCountImgFrame;
    commentCountLabel.frame = _listItem.blogLayoutInfo.commentCountLbFrame;
    
    bottomLine.frame = CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1);
    
    rowHeight = _listItem.rowHeight;
}

- (void)setListItem:(OSCListItem *)listItem
{
    _listItem = listItem;
    
    titleLabel.attributedText = [_listItem attributedTitle];
    descLabel.text = _listItem.body;
    
    nameLabel.text = _listItem.author.name;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:listItem.pubDate];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:date]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    [timeLabel setAttributedText:attributedString];
    
    viewCountLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.view];
    commentCountLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.comment];
    
    [self layoutSubviews];
}

@end
