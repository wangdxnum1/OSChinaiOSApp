//
//  OSCTweetRecommendCollectionCell.m
//  iosapp
//
//  Created by 王恒 on 16/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetRecommendCollectionCell.h"
#import "UIImageView+CornerRadius.h"
#import "UIColor+Util.h"
#import "Utils.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCTweetRecommendCollectionCell ()

@property (nonatomic,strong) NSMutableArray *lineViewArr;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) CellBottomView *bottomView;
@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation OSCTweetRecommendCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    _lineViewArr = [NSMutableArray array];
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self addContentView];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)addContentView{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 48)];
    _imageView.backgroundColor = [UIColor navigationbarColor];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
    _titleLabel = [[UILabel alloc] initWithFrame:_imageView.frame];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_imageView addSubview:_titleLabel];
    
    for (int i = 0; i < 3; i ++) {
        CellLineView *lineView = [[CellLineView alloc] initWithFrame:CGRectMake( 0, 20 + 60 * i + CGRectGetHeight(_imageView.frame), CGRectGetWidth(self.contentView.frame), 40)];
        [_lineViewArr addObject:lineView];
        [self.contentView addSubview:lineView];
    }

    _bottomView = [[CellBottomView alloc] init];
    [self.contentView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@(40));
    }];
    
    //线
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHex:0xd2d2d2];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_bottomView.mas_top);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@(1));
    }];
}

- (void)setContentArray:(NSArray *)contentArray{

    for (int i = 0; i < contentArray.count; i++) {
        CellLineView *lineView = _lineViewArr[i];
        OSCTweetItem *item = contentArray[i];
        lineView.contentStr = item.content;
        lineView.imageUrl = item.author.portrait;
        lineView.frame = CGRectMake(0, 16 + 56 * i + CGRectGetHeight(_titleLabel.frame), CGRectGetWidth(self.contentView.frame), 40);
        [lineView showCurLineCell];
    }
    for (int j = (int)contentArray.count; j < 3; j++) {
        CellLineView *lineView = _lineViewArr[j];
        lineView.frame = CGRectMake(0, 0, 0, 0);
        [lineView hideCurLineCell];
    }
}

- (void)setType:(TopicRecommedTweetType)type{
    UIImage *titleImage = [UIImage imageNamed:kTopicRecommedTweetImageArray[type]];
    _imageView.image = titleImage;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    _titleLabel.text = [NSString stringWithFormat:@"%@",_title];
}

- (void)setPeopleCount:(NSInteger)peopleCount{
    _peopleCount =peopleCount;
    _bottomView.peopleNumber = [NSString stringWithFormat:@"%ld",_peopleCount];
}

@end




@interface CellLineView ()

{
    UITextView *_contentTextV;
    UIImageView *_userImage;
}

@end

@implementation CellLineView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _userImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    [_userImage zy_cornerRadiusAdvance:20 rectCornerType:UIRectCornerAllCorners];
    [self addSubview:_userImage];
    
    _contentTextV = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_userImage.frame) + 8, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(_userImage.frame) - 20, CGRectGetHeight(self.frame))];
    _contentTextV.textColor = [UIColor colorWithHex:0x111111];
    _contentTextV.font = [UIFont systemFontOfSize:14.0];
    _contentTextV.editable = NO;
    _contentTextV.userInteractionEnabled = NO;
    _contentTextV.scrollEnabled = NO;
    [_contentTextV setTextContainerInset:UIEdgeInsetsZero];
    _contentTextV.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentTextV.textContainer.maximumNumberOfLines = 2;
    [self addSubview:_contentTextV];
}

- (void)setContentStr:(NSString *)contentStr{
    _contentStr = contentStr;
    _contentTextV.attributedText = [Utils contentStringFromRawString:contentStr];
}

- (void)setImageUrl:(NSString *)imageUrl{
    _imageUrl = imageUrl;
    [_userImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default-portrait"]];
}

- (void)showCurLineCell{
    _userImage.frame = CGRectMake(20, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame));
    _contentTextV.frame = CGRectMake(CGRectGetMaxX(_userImage.frame) + 10, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(_userImage.frame) - 30, CGRectGetHeight(self.frame));
}

- (void)hideCurLineCell{
    _contentTextV.frame = CGRectMake(0, 0, 0, 0);
    _userImage.frame = CGRectMake(0, 0, 0, 0);
}

@end






@interface CellBottomView ()

@property (nonatomic,strong) UILabel *peopleLabel;

@end

@implementation CellBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xf8f8f8];
        [self addContentView];
    }
    return self;
}

- (void)addContentView{
    _peopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
    _peopleLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    _peopleLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_peopleLabel];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake( kScreenSize.width - 40, 10, 20, 20)];
//    imageView.backgroundColor = [UIColor redColor];
//    imageView.image = [UIImage imageNamed:@"ic_arrow_right"];
//    [self addSubview:imageView];
}

- (void)setPeopleNumber:(NSString *)peopleNumber{
    _peopleNumber = peopleNumber;
    _peopleLabel.text = [NSString stringWithFormat:@"共有  %@  人参加",peopleNumber];
}

@end
