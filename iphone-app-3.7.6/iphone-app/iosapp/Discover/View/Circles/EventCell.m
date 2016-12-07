//
//  EventCell.m
//  iosapp
//
//  Created by ChanAetern on 12/1/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EventCell.h"
#import "OSCEvent.h"
#import "Utils.h"
#import "Config.h"
#import "AppDelegate.h"

@interface EventCell()

@property (nonatomic, strong) NSMutableArray *clientAndCommentConstraints;
@property (nonatomic, strong) NSMutableArray *imageConstraints;
@property (nonatomic, strong) NSMutableArray *replyConstraints;

@end

@implementation EventCell

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
    
    _actionLabel = [UILabel new];
    _actionLabel.numberOfLines = 0;
    _actionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _actionLabel.font = [UIFont systemFontOfSize:14];
    _actionLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_actionLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_timeLabel];
    
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [EventCell initContetTextView:_contentTextView];
    [self.contentView addSubview:_contentTextView];
    
    _thumbnail = [UIImageView new];
    _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnail.clipsToBounds = YES;
    _thumbnail.userInteractionEnabled = YES;
    [self.contentView addSubview:_thumbnail];
    
    _referenceText = [UITextView new];
    _referenceText.scrollEnabled = NO;
    _referenceText.editable = NO;
    _referenceText.userInteractionEnabled = NO;
    [self.contentView addSubview:_referenceText];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        _referenceText.backgroundColor = [UIColor colorWithRed:75.0/255 green:75.0/255 blue:75.0/255 alpha:1.0];
        _referenceText.textColor = [UIColor whiteColor];
    } else {
        _referenceText.backgroundColor = [UIColor colorWithHex:0xDEDEDE];
    }
    
    _appclientLabel = [UILabel new];
    _appclientLabel.font = [UIFont systemFontOfSize:12];
    _appclientLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_appclientLabel];
    
    _commentCount = [UILabel new];
    _commentCount.font = [UIFont systemFontOfSize:12];
    _commentCount.textColor = [UIColor grayColor];
    [self.contentView addSubview:_commentCount];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _actionLabel, _timeLabel, _appclientLabel, _contentTextView, _commentCount, _thumbnail, _referenceText);
    NSDictionary *metrics = @{@"lineHeight" : @([UIFont systemFontOfSize:14].lineHeight)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_portrait(36)]-5-[_authorLabel]-5-[_timeLabel]-5-|"
                                                                             options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_authorLabel(>=lineHeight@900)]-3-[_actionLabel(>=lineHeight@900)]-5-[_contentTextView(>=lineHeight@900)]"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]->=0-[_actionLabel]->=0-[_contentTextView]"
                                                                             options:NSLayoutFormatAlignAllRight metrics:nil views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentTextView]-<=5-[_referenceText(>=0@500)]-<=5-[_thumbnail]-<=5-[_appclientLabel(>=lineHeight@500)]-8-|"
                                      // 这里referenceText 跟 thumbnail 的位置应该交换，但因为交换后图片会上移(referenceText占位)，所以暂时这样，以后应处理。
                                                                             options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_thumbnail(80)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentTextView]-<=5@500-[_referenceText]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentTextView]-<=5@500-[_thumbnail]"
                                                                             options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_appclientLabel]->=0-[_commentCount]-5-|"
                                                                             options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}

- (void)setContentWithEvent:(OSCEvent *)event
{
    [_portrait loadPortrait:event.portraitURL];
    [_authorLabel setText:event.author];
    [_timeLabel setText:[event.pubDate timeAgoSinceNow]];
    [_appclientLabel setAttributedText:[Utils getAppclient:event.appclient]];
    [_actionLabel setAttributedText:event.actionStr];
    [_commentCount setAttributedText:event.attributedCommentCount];
    [_contentTextView setAttributedText:[EventCell contentStringFromRawString:event.message]];
    
    if (event.hasReference) {
        [_referenceText setText:[NSString stringWithFormat:@"%@: %@", event.objectReply[0], event.objectReply[1]]];
        _referenceText.hidden = NO;
    } else {
        _referenceText.hidden = YES;
    }
    
    _appclientLabel.hidden = !event.shouleShowClientOrCommentCount;
    _commentCount.hidden = !event.shouleShowClientOrCommentCount;
    _thumbnail.hidden = !event.hasAnImage;
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
