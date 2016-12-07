//
//  TweetCell.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "TweetCell.h"
#import "OSCTweet.h"
#import "OSCUser.h"
#import "Utils.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        _thumbnailConstraints = [NSArray new];
        _noThumbnailConstraints = [NSArray new];
        
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
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.userInteractionEnabled = YES;
    [_portrait setCornerRadius:5.0];
    [self.contentView addSubview:_portrait];

    _authorLabel = [UILabel new];
    _authorLabel.font = [UIFont boldSystemFontOfSize:14];
    _authorLabel.userInteractionEnabled = YES;
    _authorLabel.textColor = [UIColor nameColor];
    [self.contentView addSubview:_authorLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_timeLabel];
    
    _appclientLabel = [UILabel new];
    _appclientLabel.font = [UIFont systemFontOfSize:12];
    _appclientLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_appclientLabel];
    
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [TweetCell initContetTextView:_contentTextView];
    [self.contentView addSubview:_contentTextView];
    
    _likeButton = [UIButton new];
    _likeButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:12];
    [self.contentView addSubview:_likeButton];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:12];
    _commentCount.textColor = [UIColor grayColor];
    [self.contentView addSubview:_commentCount];
    
    _thumbnail = [UIImageView new];
    _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnail.clipsToBounds = YES;
    _thumbnail.userInteractionEnabled = YES;
    [self.contentView addSubview:_thumbnail];
    
    //点赞列表
    _likeListLabel = [UILabel new];
    _likeListLabel.numberOfLines = 0;
    _likeListLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _likeListLabel.font = [UIFont systemFontOfSize:12];
    _likeListLabel.userInteractionEnabled = YES;
    _likeListLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_likeListLabel];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentTextView, _likeButton, _commentCount, _likeListLabel, _thumbnail);
    

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_authorLabel]-8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_authorLabel]-5-[_contentTextView]-<=6-[_thumbnail]-<=6-[_likeListLabel]-6-[_timeLabel]-5-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
        
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-10-[_appclientLabel]->=5-[_likeButton(30)]-5-[_commentCount]-8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_likeListLabel]-8-|" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_authorLabel  attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                                                    toItem:_contentTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}

- (void)setContentWithTweet:(OSCTweet *)tweet
{
    [_portrait loadPortrait:tweet.portraitURL];
    [_authorLabel setText:tweet.author];
    
    [_timeLabel setAttributedText:[Utils attributedTimeString:tweet.pubDate]];
    [_commentCount setAttributedText:tweet.attributedCommentCount];
    [_appclientLabel setAttributedText:[Utils getAppclient:tweet.appclient]];
    if (tweet.isLike) {
        [_likeButton setTitle:[NSString fontAwesomeIconStringForEnum:FAThumbsUp] forState:UIControlStateNormal];
        [_likeButton setTitleColor:[UIColor nameColor] forState:UIControlStateNormal];
    } else {
        [_likeButton setTitle:[NSString fontAwesomeIconStringForEnum:FAThumbsOUp] forState:UIControlStateNormal];
        [_likeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    // 添加语音图片
    if (tweet.attach.length) {
        //有语音
        NSTextAttachment *textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:@"audioTweet"];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        NSMutableAttributedString *attributedTweetBody = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
        [attributedTweetBody appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [attributedTweetBody appendAttributedString:[TweetCell contentStringFromRawString:tweet.body]];
        
        [_contentTextView setAttributedText:attributedTweetBody];
    } else {
        [_contentTextView setAttributedText:[TweetCell contentStringFromRawString:tweet.body]];
    }
    
    [_likeListLabel setAttributedText:tweet.likersString];
    if (tweet.likeList.count > 0) {
        _likeListLabel.hidden = NO;
    } else {
        _likeListLabel.hidden = YES;
    }
    
}


#pragma mark - 处理长按操作

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return _canPerformAction(self, action);
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)copyText:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentTextView.text];
}

- (void)deleteObject:(id)sender
{
    _deleteObject(self);
}


#pragma mark - class methods

+ (void)initContetTextView:(UITextView*)textView
{
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont boldSystemFontOfSize:15.0];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
    textView.linkTextAttributes = @{
                                 NSForegroundColorAttributeName: [UIColor nameColor],
                                 NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
                                 };
}

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0, mutableAttrString.length)];
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                inRange:NSMakeRange(0, mutableAttrString.length)
                                options:0
                             usingBlock:^(id value, NSRange range, BOOL *stop) {
                                 if (value) {
                                     [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                 }
                             }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}


#pragma mark - prepare for reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _thumbnail.image = nil;
}


@end
