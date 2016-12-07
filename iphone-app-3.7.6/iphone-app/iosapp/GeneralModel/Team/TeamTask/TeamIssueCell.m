//
//  TeamIssueCell.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamIssueCell.h"
#import "Utils.h"
#import "TeamIssue.h"

#import "NSString+FontAwesome.h"

@implementation TeamIssueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubviews
{
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_titleLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_timeLabel];
    
    _commentLabel = [UILabel new];
    _commentLabel.font = [UIFont systemFontOfSize:12];
    _commentLabel.textColor = [UIColor colorWithHex:0xA0A3A7];
    [self.contentView addSubview:_commentLabel];
    
    _assignmentLabel = [UILabel new];
    _assignmentLabel.font = [UIFont systemFontOfSize:12];
    _assignmentLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_assignmentLabel];
    
    _extraInfoLabel = [UILabel new];
    _extraInfoLabel.font = [UIFont systemFontOfSize:12];
    _extraInfoLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_extraInfoLabel];
    
    _projectNameLabel = [UILabel new];
    _projectNameLabel.numberOfLines = 0;
    _projectNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _projectNameLabel.font = [UIFont systemFontOfSize:13];
    _projectNameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_projectNameLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _projectNameLabel, _extraInfoLabel, _assignmentLabel, _timeLabel, _commentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-8-[_projectNameLabel]-<=8-[_extraInfoLabel]-8-[_assignmentLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_titleLabel]-8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_projectNameLabel]-8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_assignmentLabel]->=0-[_commentLabel]-8-[_timeLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}


- (void)setContentWithIssue:(TeamIssue *)issue
{
    _titleLabel.attributedText = issue.attributedIssueTitle;
    
    _projectNameLabel.text = issue.project.projectName;
    _commentLabel.attributedText = [Utils attributedCommentCount:issue.replyCount];
    _timeLabel.attributedText = [Utils attributedTimeString:issue.createTime];
    
    if (issue.hasExtraInfo) {
        NSMutableString *extraInfo = [NSMutableString new];
        
        if (issue.deadline) {
            [extraInfo appendString:[issue.deadline formattedDateWithStyle:NSDateFormatterMediumStyle]];
        }
        
        if (issue.attachmentsCount) {
            [extraInfo appendString:[NSString stringWithFormat:@"%d个附件 ", issue.attachmentsCount]];
        }
        
        if (issue.childIssuesCount) {
            [extraInfo appendString:[NSString stringWithFormat:@"子任务(%d/%d)", issue.childIssuesCount - issue.closedChildIssuesCount, issue.childIssuesCount]];
        }
        
        if (issue.relatedIssuesCount) {
            [extraInfo appendString:[NSString stringWithFormat:@"%d个关联任务", issue.attachmentsCount]];
        }
        
        _extraInfoLabel.text = extraInfo;
    } else {
        _extraInfoLabel.text = @"";
    }
    
    if (issue.user.name) {
        _assignmentLabel.text = [NSString stringWithFormat:@"%@ 指派给 %@", issue.author.name, issue.user.name];
    } else {
        _assignmentLabel.text = [NSString stringWithFormat:@"%@ 未指派", issue.author.name];
    }
}

@end
