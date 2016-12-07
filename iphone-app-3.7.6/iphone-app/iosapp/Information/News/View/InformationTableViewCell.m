//
//  InformationTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/5/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "InformationTableViewCell.h"
#import "OSCInformation.h"
#import "OSCListItem.h"
#import "Utils.h"
#import "UIColor+Util.h"

NSString* InformationTableViewCell_IdentifierString = @"InformationTableViewCellReuseIdenfitier";

@interface InformationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *recommendImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDistanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;

@end

@implementation InformationTableViewCell

- (void)prepareForReuse{
    [super prepareForReuse];
    _titleLabel.textColor = [UIColor newTitleColor];
    _descLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _titleLabel.textColor = [UIColor newTitleColor];
}

+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString
{
    InformationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifierString
                                                                     forIndexPath:indexPath];

    return cell;
}


#pragma mark - seeting VM
-(void)setViewModel:(OSCInformation* )viewModel{
    _viewModel = viewModel;

    _titleLabel.textColor = [UIColor newTitleColor];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:viewModel.pubDate];
    NSDate *systemDate = [formatter dateFromString:_systemTimeDate];
    NSDate *subDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", [_systemTimeDate componentsSeparatedByString:@" "][0]]];
    
    int timeSecond = [systemDate timeIntervalSince1970] - [date timeIntervalSince1970];
    int subTime = [systemDate timeIntervalSince1970] - [subDate timeIntervalSince1970];
    
    if (timeSecond <= subTime) {//"推荐"新闻
        _recommendImageView.hidden = NO;
        _titleLabel.text = [NSString stringWithFormat:@"     %@",viewModel.title];
    } else{//不是"推荐"新闻 普通新闻
        _recommendImageView.hidden = YES;
        _titleLabel.text = viewModel.title;
    }
    
    _descLabel.text = viewModel.body;
    _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)viewModel.commentCount];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld",(long)viewModel.viewCount];
    
    [_timeDistanceLabel setAttributedText:[Utils attributedTimeString:date]];
}


- (void)setListItem:(OSCListItem *)listItem{
    _listItem = listItem;
    _recommendImageView.hidden = YES;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate* date = [formatter dateFromString:listItem.pubDate];

    _titleLabel.attributedText = listItem.attributedTitle;
    _descLabel.text = listItem.body;
    _commentLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.comment];
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld",(long)listItem.statistics.view];
    
    [_timeDistanceLabel setAttributedText:[Utils attributedTimeString:date]];
}

- (void)setCompleteRead{
    _titleLabel.textColor = [UIColor lightGrayColor];
    _descLabel.textColor = [UIColor lightGrayColor];
}

@end
