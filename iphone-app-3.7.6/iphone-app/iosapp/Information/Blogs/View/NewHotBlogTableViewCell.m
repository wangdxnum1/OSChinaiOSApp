//
//  NewHotBlogTableViewCell.m
//  iosapp
//
//  Created by Holden on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewHotBlogTableViewCell.h"
#import "OSCNewHotBlog.h"
#import "OSCListItem.h"
#import "Utils.h"
#import "UIColor+Util.h"

@implementation NewHotBlogTableViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    _titleLabel.textColor = [UIColor newTitleColor];
    _descLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
}

+ (instancetype)returnReuseNewHotBlogCellWithTableView:(UITableView *)tableView
                                             indexPath:(NSIndexPath *)indexPath
                                            identifier:(NSString *)reuseIdentifier
{
    NewHotBlogTableViewCell* blogCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    return blogCell;
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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor newCellColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setBlog:(OSCNewHotBlog *)blog
{
    _titleLabel.attributedText = blog.attributedTitleString;
    _descLabel.text = blog.body;
    _authorLabel.text = blog.author;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:[NSDate dateFromString:blog.pubDate]]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    _timeLabel.attributedText = attributedString;
    
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", blog.commentCount];
    _viewCountLabel.text = [NSString stringWithFormat:@"%d", blog.viewCount];
}

- (void)setListItem:(OSCListItem *)listItem{
    _titleLabel.attributedText = listItem.attributedTitle;
    _descLabel.text = listItem.body;
    _authorLabel.text = listItem.author.name;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils attributedTimeString:[NSDate dateFromString:listItem.pubDate]]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor newAssistTextColor] range:NSMakeRange(0, attributedString.length)];
    _timeLabel.attributedText = attributedString;
    
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)listItem.statistics.comment];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)listItem.statistics.view];
}

- (void)setCompleteRead{
    _titleLabel.textColor = [UIColor lightGrayColor];
    _descLabel.textColor = [UIColor lightGrayColor];
}

@end
