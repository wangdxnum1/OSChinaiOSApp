//
//  OSCResultTableViewCell.m
//  iosapp
//
//  Created by 王恒 on 16/10/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCResultTableViewCell.h"
#import "UIColor+Util.h"
#import "UIImageView+CornerRadius.h"
#import "OSCSearchItem.h"
#import "OSCUserItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCResultCoustomCell ()

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *contentLable;

@end

@implementation OSCResultCoustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addContentView];
    }
    return self;
}

-(void)addContentView{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, kScreenSize.width - 32, 20)];
    _titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _titleLabel.textColor = [UIColor colorWithHex:0x111111];
    [self.contentView addSubview:_titleLabel];
    
    _contentLable = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_titleLabel.frame) + 4, kScreenSize.width - 32, 32)];
    _contentLable.font = [UIFont systemFontOfSize:13];
    _contentLable.textColor = [UIColor colorWithHex:0x6a6a6a];
    _contentLable.numberOfLines = 2;
    [self.contentView addSubview:_contentLable];
}

-(void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = title;
}

-(void)setContent:(NSString *)content{
    _content = content;
    _contentLable.text = content;
}

@end



@interface OSCResultPersonCell ()

@property (weak, nonatomic) IBOutlet UIImageView *UserImageView;

@property (weak, nonatomic) IBOutlet UILabel *UserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *UserPresentLabel;
@property (weak, nonatomic) IBOutlet UILabel *UserScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *UserStarLabel;
@property (weak, nonatomic) IBOutlet UILabel *UserFansLabel;

@end

@implementation OSCResultPersonCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [_UserImageView zy_cornerRadiusAdvance:22.5 rectCornerType:UIRectCornerAllCorners];
}

-(void)setModel:(OSCSearchPeopleItem *)model{
    _model = model;
    [_UserImageView sd_setImageWithURL:[NSURL URLWithString:model.portrait] placeholderImage:[UIImage imageNamed:@"default-portrait"]];
    _UserNameLabel.text = model.name;
    _UserPresentLabel.text = model.desc;
    OSCUserStatistics *statistic = model.statistics;
    _UserScoreLabel.text = [NSString stringWithFormat:@"积分 %ld ",statistic.score];
    _UserStarLabel.text = [NSString stringWithFormat:@"| 关注 %ld ",statistic.follow];
    _UserFansLabel.text = [NSString stringWithFormat:@"| 粉丝 %ld",statistic.fans];
    if(CGRectGetMaxX(_UserFansLabel.frame) > kScreenSize.width - 16){
        _UserScoreLabel.preferredMaxLayoutWidth = kScreenSize.width/3;
        _UserStarLabel.preferredMaxLayoutWidth = kScreenSize.width/3;
        _UserFansLabel.preferredMaxLayoutWidth = kScreenSize.width/3;
    }
}

@end

