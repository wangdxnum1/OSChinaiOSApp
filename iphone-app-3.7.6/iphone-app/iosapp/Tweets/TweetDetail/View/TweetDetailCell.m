//
//  TweetDetailCell.m
//  iosapp
//
//  Created by Holden on 16/7/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetDetailCell.h"
#import "Utils.h"
#import "OSCTweetItem.h"
#import "UIImageView+CornerRadius.h"

#import <Masonry.h>

@implementation TweetDetailCell{
    __weak UIImageView* _imageTypeLogo;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initWithSubViews];
        [self setLayout];
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _userPortrait.userInteractionEnabled = YES;
        _likeCountIv.userInteractionEnabled = YES;
        _commentImage.userInteractionEnabled = YES;
        _tweetImageView.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark - 初始化
- (void)initWithSubViews
{
    _userPortrait = [UIImageView new];
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    _userPortrait.userInteractionEnabled = YES;
    [_userPortrait setCornerRadius:22];
    [_userPortrait zy_cornerRadiusAdvance:22 rectCornerType:UIRectCornerAllCorners];
    [self.contentView addSubview:_userPortrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont boldSystemFontOfSize:15];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor newTitleColor];
    [self.contentView addSubview:_nameLabel];
    
    _descTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [TweetDetailCell initContetTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    _tweetImageView = [UIImageView new];
    _tweetImageView.contentMode = UIViewContentModeScaleAspectFill;
    _tweetImageView.clipsToBounds = YES;
    _tweetImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_tweetImageView];
    
//    imageTypeLogo
    UIImageView* imageTypeLogo = [[UIImageView alloc]init];
    _imageTypeLogo = imageTypeLogo;
    _imageTypeLogo.userInteractionEnabled = NO;
    _imageTypeLogo.hidden = YES;
    [_tweetImageView addSubview:_imageTypeLogo];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor newAssistTextColor];
    [self.contentView addSubview:_timeLabel];
    
    _likeCountIv = [UIImageView new];
    [_likeCountIv setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    _likeCountIv.contentMode = UIViewContentModeRight;
    [self.contentView addSubview:_likeCountIv];
    
    _commentImage = [UIImageView new];
    _commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    [self.contentView addSubview:_commentImage];
}

- (void)setLayout
{
    
#pragma mark - change using Masnory add Constraints
    
    [_userPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@45);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userPortrait.mas_centerY);
        make.left.equalTo(_userPortrait.mas_right).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_userPortrait.mas_bottom).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_tweetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
    }];
    
    [_imageTypeLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(_tweetImageView).with.offset(-2);
        make.width.equalTo(@18);
        make.height.equalTo(@11);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_tweetImageView.mas_bottom).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_likeCountIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentImage.mas_left).with.offset(-16);
    }];
}

+ (void)initContetTextView:(UITextView*)textView
{
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = [UIColor newTitleColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
}

#pragma mark - set Tweet
-(void)setTweet:(OSCTweetItem *)tweet{
    if (!tweet) { return; }
    _tweet = tweet;
    
    if (_tweet.images.count == 1) {
        OSCTweetImages* imageData = [tweet.images lastObject];
        if ([imageData.thumb hasSuffix:@".gif"]) {
            _imageTypeLogo.image = [UIImage imageNamed:@"gif"];
            _imageTypeLogo.hidden = NO;
        }
        [_tweetImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
            make.width.equalTo(@(tweet.imageFrame.size.width));
            make.height.equalTo(@(tweet.imageFrame.size.height));
        }];
    } else {
        [_tweetImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_descTextView.mas_bottom).with.offset(0);
        }];
    }
}
@end
