//
//  CommentCell.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "CommentCell.h"
#import "OSCComment.h"
#import "Utils.h"
#import "Config.h"
#import "AppDelegate.h"

@interface CommentCell ()

@property (nonatomic, strong) UIView *currentContainer;

@end

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self initSubviews];
        [self setLayout];
    }
    
    return self;
}

- (void)initSubviews
{
    self.portrait = [UIImageView new];
    self.portrait.contentMode = UIViewContentModeScaleAspectFit;
    self.portrait.userInteractionEnabled = YES;
    [self.portrait setCornerRadius:5.0];
    [self.contentView addSubview:self.portrait];
    
    self.authorLabel = [UILabel new];
    self.authorLabel.font = [UIFont boldSystemFontOfSize:14];
    self.authorLabel.textColor = [UIColor nameColor];
    self.authorLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:self.authorLabel];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.timeLabel];
    
    self.appclientLabel = [UILabel new];
    self.appclientLabel.font = [UIFont systemFontOfSize:12];
    self.appclientLabel .textAlignment = NSTextAlignmentLeft;
    self.appclientLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.appclientLabel];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:self.contentLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _authorLabel, _timeLabel, _appclientLabel, _contentLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_authorLabel]-8-|"
                                                                             options:0 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_authorLabel]->=5-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentLabel]-8-[_timeLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_timeLabel]-10-[_appclientLabel]->=8-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil views:views]];
}



- (void)setContentWithComment:(OSCComment *)comment
{
    [_portrait loadPortrait:comment.portraitURL];
    _authorLabel.text = comment.author;
    _timeLabel.attributedText = [Utils attributedTimeString:comment.pubDate];
    _appclientLabel.attributedText = [Utils getAppclient:comment.appclient];
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.content]];
    if (comment.replies.count > 0) {
        [contentString appendAttributedString:[OSCComment attributedTextFromReplies:comment.replies]];
    }
    [_contentLabel setAttributedText:contentString];
    
    [self dealWithReferences:comment.references];
}


- (void)dealWithReferences:(NSArray *)references
{
    if (references.count == 0) {return;}
    
    _currentContainer = [UIView new];
    [self.contentView addSubview:_currentContainer];
    _currentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_authorLabel, _contentLabel, _currentContainer);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_authorLabel]-5-[_currentContainer]-8-[_contentLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    //for (OSCReference *reference in [references reverseObjectEnumerator]) {
    [references enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OSCReference *reference, NSUInteger idx, BOOL *stop) {
        [_currentContainer setBorderWidth:1.0 andColor:[UIColor lightGrayColor]];
        _currentContainer.backgroundColor = [UIColor colorWithHex:0xFFFAF0];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor titleColor];
        
        NSMutableAttributedString *referenceText = [[NSMutableAttributedString alloc] initWithString:reference.title
                                                                                          attributes:@{NSForegroundColorAttributeName:[UIColor nameColor]}];
        [referenceText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", reference.body]]];
        label.attributedText = referenceText;
        
        [_currentContainer addSubview:label];
        
        UIView *container = [UIView new];
        [_currentContainer addSubview:container];
        
        ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
        if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
            _currentContainer.backgroundColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0];
            label.backgroundColor = [UIColor clearColor];
        }
        else {
            _currentContainer.backgroundColor = [UIColor colorWithHex:0xFFFAF0];
            label.backgroundColor = [UIColor colorWithHex:0xFFFAF0];
        }
        
        for (UIView *view in _currentContainer.subviews) {
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        NSDictionary *views = NSDictionaryOfVariableBindings(label, container);
        
        if (idx == 0) {
            container.hidden = YES;
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[label]-4-|"
                                                                                     options:0 metrics:nil views:views]];
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[label]-4-|" options:0 metrics:nil views:views]];
        } else {
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[container]-<=5-[label]-4-|"
                                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                                      metrics:nil views:views]];
            
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[container]-4-|" options:0 metrics:nil views:views]];
        }
        
        _currentContainer = container;
    }];
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
    [pasteBoard setString:_contentLabel.text];
}

- (void)deleteObject:(id)sender
{
    _deleteObject(self);
}




@end
