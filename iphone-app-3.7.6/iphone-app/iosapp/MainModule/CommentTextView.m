//
//  CommentTextView.m
//  iosapp
//
//  Created by 王恒 on 16/11/8.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "CommentTextView.h"
#import "UIColor+Util.h"
#import "Utils.h"
#import <Masonry.h>
#import <MBProgressHUD.h>

#define kMaxHeight 100
#define kMinHeight 29
#define kMaxLenth 160

@interface CommentTextView () <UITextViewDelegate>

@property (nonatomic,strong) UILabel *placeholderLabel;
@property (nonatomic,assign) BOOL isCompleteMax;
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation CommentTextView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setSelf];
    [self addContentViewWithFont:self.font];
}

- (instancetype)initWithFrame:(CGRect)frame
              WithPlaceholder:(NSString *)placeholder
                     WithFont:(UIFont *)font{
    _placeholder = placeholder;
    self = [super initWithFrame:frame];
    if (self) {
        [self setSelf];
        [self addContentViewWithFont:font];
    }
    return self;
}

- (void)setSelf{
    [self setTextContainerInset:UIEdgeInsetsMake(5, 0, 5, 0)];
    self.delegate = self;
    self.layer.borderColor = [[UIColor colorWithHex:0xc7c7cc] CGColor];
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 4;
    self.scrollEnabled = NO;
    self.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textContainer.maximumNumberOfLines = 1;
}

- (void)addContentViewWithFont:(UIFont *)font{
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _placeholderLabel.textColor = [UIColor colorWithHex:0xc8c8ce];
    _placeholderLabel.text = @"发表评论";
    _placeholderLabel.font = font;
    [self addSubview:_placeholderLabel];
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    _placeholderLabel.text = _placeholder;
}

#pragma --mark UITextViewDelegate
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]) {
//        if ([self.commentTextViewDelegate respondsToSelector:@selector(clickReturn)]) {
//            [self.commentTextViewDelegate clickReturn];
//        }
//        return YES;
//    }else{
//        if (_maxLenth == 0) {
//            _maxLenth = kMaxLenth;
//        }
//        if (textView.text.length >= _maxLenth && ![text isEqualToString:@""]) {
//            [self getHud];
//            return NO;
//        }
//        return YES;
//    }
//}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([self.commentTextViewDelegate respondsToSelector:@selector(ClickTextViewWithString:)]) {
        NSString *textString;
        if (self.text.length>0) {
            textString = [self.text substringWithRange:NSMakeRange(4, textView.text.length - 4)];
        }
        [self.commentTextViewDelegate ClickTextViewWithString:textString];
    }
    if ([self.commentTextViewDelegate respondsToSelector:@selector(ClickTextViewWithAttribute:)]) {
        NSAttributedString *attibute;
        if (textView.attributedText.length > 0) {
            attibute = [textView.attributedText attributedSubstringFromRange:NSMakeRange(4, textView.attributedText.length - 4)];
        }
        [self.commentTextViewDelegate ClickTextViewWithAttribute:attibute];
    }
    return NO;
}

//- (void)textViewDidChange:(UITextView *)textView{
//    if (_maxLenth == 0) {
//        _maxLenth = kMaxLenth;
//    }
//    if (textView.text.length > _maxLenth) {
//        NSRange range = NSMakeRange(0, _maxLenth);
//        NSString *string = [textView.text substringWithRange:range];
//        textView.text = string;
//        [self getHud];
//    }
//    if (textView.text.length == 0) {
//        _placeholderLabel.hidden = NO;
//    }else{
//        _placeholderLabel.hidden = YES;
//    }

    //自动换行
//    if (self.contentSize.height < kMaxHeight && self.contentSize.height > 29) {
//        if ([self.commentTextViewDelegate respondsToSelector:@selector(textViewChangeWithTargetHeight:)]) {
//            [self.commentTextViewDelegate textViewChangeWithTargetHeight:self.contentSize.height];
//        }
//        _isCompleteMax = NO;
//    }else if (self.contentSize.height <= 29){
//        if ([self.commentTextViewDelegate respondsToSelector:@selector(textViewChangeWithTargetHeight:)]) {
//            [self.commentTextViewDelegate textViewChangeWithTargetHeight:29];
//        }
//        _isCompleteMax = NO;
//    }else{
//        _isCompleteMax = YES;
//    }
//}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (!_isCompleteMax) {
//        [scrollView setContentOffset:CGPointZero];
//    }
//}

- (NSString *)getPlace{
    _placeholder = _placeholderLabel.text;
    return _placeholder;
}

- (void)handleAttributeWithString:(NSString *)textString{
    if (textString.length == 0 || textString == nil) {
        self.attributedText = nil;
        _placeholderLabel.hidden = NO;
    }else{
        _placeholderLabel.hidden = YES;
        NSString *targetString = [NSString stringWithFormat:@"[草稿]%@",textString];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:targetString];
        NSRange firstRange = NSMakeRange(0, 4);
        [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:firstRange];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(0, targetString.length)];
        self.attributedText = attributeString;
    }
}

- (void)handleAttributeWithAttribute:(NSAttributedString *)attribute{
    if (attribute.length != 0) {
        _placeholderLabel.hidden = YES;
        NSString *targetString = [NSString stringWithFormat:@"[草稿]"];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:targetString];
        NSRange firstRange = NSMakeRange(0, 4);
        [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:firstRange];
        [attributeString appendAttributedString:attribute];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0] range:NSMakeRange(0, attributeString.length)];
        self.attributedText = attributeString;
    }else{
        self.attributedText = nil;
        _placeholderLabel.hidden = NO;
    }
}

- (void)getHud{
    _hud = [Utils createHUD];
    _hud.mode = MBProgressHUDModeText;
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    _hud.detailsLabel.text = @"不能输入更多";
    [_hud hideAnimated:YES afterDelay:1];
}

@end
