//
//  ProjectCell.m
//  iosapp
//
//  Created by Holden on 15/4/27.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "ProjectCell.h"
#import "UIColor+Util.h"
#import "TeamProject.h"
#import "NSString+FontAwesome.h"

@interface ProjectCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation ProjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
    }
    return self;
}

- (void)initSubviews
{
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = [UIColor titleColor];
    [self.contentView addSubview:_titleLabel];
    
    _countLabel = [UILabel new];
    _countLabel.font = [UIFont systemFontOfSize:13];
    _countLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_countLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_titleLabel, _countLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_titleLabel]-15-|" options:0 metrics:nil views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_titleLabel]-8-[_countLabel]-15-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
}


- (void)setContentWithTeamProject:(TeamProject *)project
{
    _countLabel.text = [NSString stringWithFormat:@"%d/%d", project.openedIssueCount, project.allIssueCount];
    _titleLabel.attributedText = project.attributedTitle;
}





@end
