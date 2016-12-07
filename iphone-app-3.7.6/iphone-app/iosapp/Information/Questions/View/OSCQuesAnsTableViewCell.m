//
//  OSCQuesAnsTableViewCell.m
//  iosapp
//
//  Created by 李萍 on 2016/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCQuesAnsTableViewCell.h"
#import "Utils.h"
#import "OSCListItem.h"
#import "UIImageView+CornerRadius.h"

#import <YYKit.h>

@implementation OSCQuesAnsTableViewCell {
    UIImageView *portraitIMView;
    UILabel *titleLabel;
    UILabel *descLabel;
    
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
    OSCQuesAnsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
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
    portraitIMView = [UIImageView new];
    portraitIMView.clipsToBounds = YES;
    [portraitIMView zy_cornerRadiusRoundingRect];
    [self.contentView addSubview:portraitIMView];
    
    titleLabel = [UILabel new];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textColor = [UIColor newTitleColor];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:titleLabel];

    descLabel = [UILabel new];
    descLabel.numberOfLines = 2;
    descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    descLabel.textColor = [UIColor newSecondTextColor];
    descLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:descLabel];
    
    nameLabel = [YYLabel new];
    nameLabel.textColor = [UIColor newAssistTextColor];
    nameLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:nameLabel];
    
    timeLabel = [YYLabel new];
    timeLabel.textColor = [UIColor newAssistTextColor];
    timeLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:timeLabel];
    
    viewCountLabel = [YYLabel new];
    viewCountLabel.textColor = [UIColor newAssistTextColor];
    viewCountLabel.font = [UIFont systemFontOfSize:10];
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
    commentCountLabel.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:commentCountLabel];
    
    bottomLine = [[UIView alloc] initWithFrame:CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1)];
    bottomLine.backgroundColor = [[UIColor colorWithHex:0xC8C7CC] colorWithAlphaComponent:0.7];
    [self.contentView addSubview:bottomLine];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    portraitIMView.frame = _listItem.questionLayoutInfo.protraitImgFrame;
    titleLabel.frame = _listItem.questionLayoutInfo.titleLbFrame;
    descLabel.frame = _listItem.questionLayoutInfo.descLbFrame;
    
    nameLabel.frame = _listItem.questionLayoutInfo.userNameLbFrame;
    timeLabel.frame = _listItem.questionLayoutInfo.timeLbFrame;
    
    viewIcon.frame = _listItem.questionLayoutInfo.viewCountImgFrame;
    viewCountLabel.frame = _listItem.questionLayoutInfo.viewCountLbFrame;
    commentIcon.frame = _listItem.questionLayoutInfo.commentCountImgFrame;
    commentCountLabel.frame = _listItem.questionLayoutInfo.commentCountLbFrame;
    bottomLine.frame = CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1);
    
    rowHeight = _listItem.rowHeight;
}

- (void)setListItem:(OSCListItem *)listItem
{
    _listItem = listItem;
    
    [portraitIMView loadPortrait:[NSURL URLWithString:_listItem.author.portrait]];
    titleLabel.text = _listItem.title;
    descLabel.text = (_listItem.body.length > 0 ? _listItem.body : @"[图片]");
    
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
