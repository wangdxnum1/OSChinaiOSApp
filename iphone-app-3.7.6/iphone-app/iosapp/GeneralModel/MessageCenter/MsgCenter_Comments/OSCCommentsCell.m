//
//  OSCCommentsCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentsCell.h"
#import "OSCMessageCenter.h"
#import "UIImageView+RadiusHandle.h"
#import "ImageDownloadHandle.h"
#import "Utils.h"
#import "Config.h"
#import "UIColor+Util.h"

@interface OSCCommentsCell ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userPortraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *originDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAndSourceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;

@end

@implementation OSCCommentsCell{
    BOOL _trackingTouch_userPortrait;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_userPortraitImageView handleCornerRadiusWithRadius:22.5];
    [self handleTextView:_descTextView];
    [_descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forwardingEvent:)]];
}
+ (instancetype)returnReuseCommentsCellWithTableView:(UITableView *)tableView
                                           indexPath:(NSIndexPath *)indexPath
                                          identifier:(NSString *)reuseIdentifier
{
    OSCCommentsCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    return cell;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView.backgroundColor = [UIColor newCellColor];;
        self.contentView.backgroundColor = [UIColor newCellColor];;
        self.backgroundColor = [UIColor newCellColor];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    }
    return self;
}

- (void)setCommentItem:(CommentItem *)commentItem{
    _commentItem = commentItem;
    
    UIImage* portraitImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:commentItem.author.portrait];
    if (!portraitImage) {
        [ImageDownloadHandle downloadImageWithUrlString:commentItem.author.portrait SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_userPortraitImageView setImage:image];
            });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_userPortraitImageView setImage:portraitImage];
        });
    }
    
    _nameLabel.text = commentItem.author.name;
    _descTextView.attributedText = [Utils contentStringFromRawString:commentItem.content];
    NSMutableAttributedString* descAtt = [[NSMutableAttributedString alloc]initWithString:[Config getOwnUserName]];
    [descAtt appendAttributedString:[[NSAttributedString alloc] initWithString:@"："]];
    [descAtt appendAttributedString:[Utils contentStringFromRawString:commentItem.origin.desc]];
    [descAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x24cf5f]} range:NSMakeRange(0, [Config getOwnUserName].length)];
    _originDescLabel.attributedText = descAtt;
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:commentItem.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)commentItem.appClient]];
    _timeAndSourceLabel.attributedText = att;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)commentItem.commentCount];
}
#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:_userPortraitImageView];
    if (CGRectContainsPoint(_userPortraitImageView.bounds, p)) {
        _trackingTouch_userPortrait = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(commentsCellDidClickUserPortrait:)]) {
            [_delegate commentsCellDidClickUserPortrait:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_userPortrait) {
        [super touchesCancelled:touches withEvent:event];
    }
}
- (void)forwardingEvent:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(textViewTouchPointProcessing:)]) {
        [_delegate textViewTouchPointProcessing:tap];
    }
}
#pragma mark --- hanleTextView
- (void)handleTextView:(UITextView *)textView{
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.textColor = [UIColor newTitleColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.delegate = self;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
    [textView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [textView setTextAlignment:NSTextAlignmentLeft];
    textView.text = @" ";
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:textView.text];
}
#pragma mark --- UITextView delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([_delegate respondsToSelector:@selector(shouldInteractTextView:URL:inRange:)]) {
        [_delegate shouldInteractTextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}

@end
