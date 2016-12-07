//
//  TweetCommentNewCell.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetCommentNewCell.h"
#import "UIImageView+Util.h"
#import "utils.h"
@implementation TweetCommentNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_portraitIv setCornerRadius:16];
    _commentTagIv.userInteractionEnabled = YES;
    _portraitIv.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setCommentModel:(OSCCommentItem *)commentModel {
    
    [self.portraitIv loadPortrait:[NSURL URLWithString:commentModel.author.portrait]];
    [self.nameLabel setText:commentModel.author.name];
    NSDate *pDate = [NSDate dateFromString:commentModel.pubDate];
    self.interalTimeLabel.attributedText = [Utils newTweetAttributedTimeString:pDate];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:commentModel.content]];
    if (commentModel.replies.count > 0) {
        [contentString appendAttributedString:[OSCCommentItem attributedTextFromReplies:commentModel.replies]];
    }
    [self.contentLabel setAttributedText:contentString];
}

#pragma mark - 处理长按操作

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canPerformAction(self, action);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copyText:(id)sender {
    self.backgroundColor = [UIColor whiteColor];
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_contentLabel.text];
}

- (void)deleteObject:(id)sender {
    self.backgroundColor = [UIColor whiteColor];
    _deleteObject(self);
}


@end
