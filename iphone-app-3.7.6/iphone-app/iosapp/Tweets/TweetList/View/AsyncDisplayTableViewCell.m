//
//  AsyncDisplayTableViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "AsyncDisplayTableViewCell.h"
#import "UIColor+Util.h"

@implementation AsyncDisplayTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    for (UIView *view in self.subviews) {
        if([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)view).delaysContentTouches = NO; // Remove touch delay for iOS 7
            break;
        }
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView.backgroundColor = [UIColor newCellColor];;
    self.contentView.backgroundColor = [UIColor newCellColor];;
    self.backgroundColor = [UIColor newCellColor];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    return self;
}

- (void)handleTextView:(UITextView *)textView{
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:descTextView_FontSize];
    textView.textColor = [UIColor newTitleColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [textView setTextContainerInset:UIEdgeInsetsZero];
    textView.textContainer.lineFragmentPadding = 0;
    [textView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
    textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [textView setTextAlignment:NSTextAlignmentLeft];
    textView.text = @" ";
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:textView.text];
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
- (void)deleteObject:(id)sender
{
    _deleteObject(self);
}

static UIImage* _likeImage;
- (UIImage* )likeImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _likeImage = [UIImage imageNamed:@"ic_thumbup_actived"];
    });
    return _likeImage;
}

static UIImage* _unlikeImage;
- (UIImage* )unlikeImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _unlikeImage = [UIImage imageNamed:@"ic_thumbup_normal"];
    });
    return _unlikeImage;
}

static UIImage* _commentImage;
- (UIImage* )commentImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _commentImage = [UIImage imageNamed:@"ic_comment_30"];
    });
    return _commentImage;
}

static UIImage* _gifImage;
- (UIImage *)gifImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gifImage = [UIImage imageNamed:@"gif"];
    });
    return _gifImage;
}
- (void)setLikeStatus:(BOOL)isLike animation:(BOOL)isNeedAnimation{
    // Covered by the subclass
}
- (void)copyText:(id)sender{
    // Covered by the subclass
}

@end





