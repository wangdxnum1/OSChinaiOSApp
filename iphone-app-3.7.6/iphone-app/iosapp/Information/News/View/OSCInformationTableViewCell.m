//
//  OSCInformationTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformationTableViewCell.h"
#import "OSCListItem.h"

#import "Utils.h"
#import <YYKit.h>

@interface OSCInformationTableViewCell ()

{
    CGFloat rowHeight ;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) YYLabel *timeLabel;
@property (nonatomic, strong) UIImageView *commentIcon;
@property (nonatomic, strong) YYLabel *commentLabel;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation OSCInformationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
        [self addContentView];
    }
    return self;
}

+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString
{
    OSCInformationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
                                                        forIndexPath:indexPath];
    
    return cell;
}

- (void)addContentView
{
    _titleLabel = [UILabel new];
    _titleLabel.textColor = [UIColor newTitleColor];
    _titleLabel.font = [UIFont systemFontOfSize:informationCell_titleLB_Font_Size];
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = [UIColor newSecondTextColor];
    _contentLabel.numberOfLines = 2;
    _contentLabel.font = [UIFont systemFontOfSize:informationCell_descLB_Font_Size];
    [self.contentView addSubview:_contentLabel];
    
    _timeLabel = [YYLabel new];
    _timeLabel.textColor = [UIColor newAssistTextColor];
    _timeLabel.font = [UIFont systemFontOfSize:informationCell_infoBar_Font_Size];
    [self.contentView addSubview:_timeLabel];
    
    _commentIcon = [UIImageView new];
    _commentIcon.contentMode = UIViewContentModeScaleAspectFit;
    _commentIcon.image = [UIImage imageNamed:@"ic_comment"];
    [self.contentView addSubview:_commentIcon];
    
    _commentLabel = [YYLabel new];
    _commentLabel.textColor = [UIColor newAssistTextColor];
    _commentLabel.font = [UIFont systemFontOfSize:informationCell_infoBar_Font_Size];
    [self.contentView addSubview:_commentLabel];
    
    _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1)];
    _bottomLine.backgroundColor = [[UIColor colorWithHex:0xC8C7CC] colorWithAlphaComponent:0.7];
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _titleLabel.frame = _listItem.informationLayoutInfo.titleLbFrame;
    _contentLabel.frame = _listItem.informationLayoutInfo.contentLbFrame;
    
    _timeLabel.frame = _listItem.informationLayoutInfo.timeLbFrame;
    _commentIcon.frame = _listItem.informationLayoutInfo.commentImgFrame;
    _commentLabel.frame = _listItem.informationLayoutInfo.commentCountLbFrame;
    
    _bottomLine.frame = CGRectMake(cell_padding_left, rowHeight-1, CGRectGetWidth(self.contentView.frame), 1);
    
    rowHeight = _listItem.rowHeight;
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    _titleLabel.attributedText = listItem.attributedTitle;
    _contentLabel.text = listItem.body;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:listItem.pubDate];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:date]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    [_timeLabel setAttributedText:attributedString];
    
    _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.comment];
    
    [self layoutSubviews];
}
#pragma mark - 

- (void)setShowCommentCount:(BOOL)showCommentCount
{
    if (showCommentCount) {
        _commentLabel.hidden = NO;
        _commentIcon.hidden = NO;
    } else {
        _commentLabel.hidden = YES;
        _commentIcon.hidden = YES;
    }
}

@end
