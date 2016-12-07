//
//  QuesAnsTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/5/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsTableViewCell.h"
#import "Utils.h"
#import "OSCQuestion.h"
#import "OSCListItem.h"
#import "ImageDownloadHandle.h"
#import "UIColor+Util.h"

@interface QuesAnsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageViewNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

@implementation QuesAnsTableViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    _titleLabel.textColor = [UIColor newTitleColor];
    _descLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
}

#pragma mark - 解固方法

- (void)awakeFromNib {
    [super awakeFromNib];

    _titleLabel.textColor = [UIColor newTitleColor];
    
    _authorLabel.preferredMaxLayoutWidth = 150;
    self.contentView.backgroundColor = [UIColor newCellColor];
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

#pragma mark - setting VM
-(void)setViewModel:(OSCQuestion *)viewModel{
    _viewModel = viewModel;
    
    [_iconImageView loadPortrait:[NSURL URLWithString:viewModel.authorPortrait]];
    _titleLabel.text = viewModel.title;
    _descLabel.text = viewModel.body;
    _authorLabel.text = viewModel.author;
    
    _pageViewNumLabel.text = [NSString stringWithFormat:@"%ld",(long)viewModel.viewCount];
    _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)viewModel.commentCount];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:viewModel.pubDate];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:date]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    [_timeLabel setAttributedText:attributedString];
}

- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    
    [_iconImageView loadPortrait:[NSURL URLWithString:listItem.author.portrait]];
    _titleLabel.text = listItem.title;
    _descLabel.text = listItem.body;
    _authorLabel.text = listItem.author.name;
    
    _pageViewNumLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.view];
    _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.comment];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:listItem.pubDate];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:date]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    [_timeLabel setAttributedText:attributedString];
}

- (void)setCompleteRead{
    _titleLabel.textColor = [UIColor lightGrayColor];
    _descLabel.textColor = [UIColor lightGrayColor];
}
@end




