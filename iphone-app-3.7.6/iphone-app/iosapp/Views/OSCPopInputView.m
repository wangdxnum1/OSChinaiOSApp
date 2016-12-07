//
//  OSCPopInputView.m
//  iosapp
//
//  Created by Graphic-one on 16/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPopInputView.h"
#import "Utils.h"

#define defaultMaxStringLenght 160

/** autoLayout */
#define atButton_and_emoji_width 32

#define atButton_left_padding_default 19
#define emjioButton_left_padding_default 57
#define forwardingButton_left_padding_default 99

@interface OSCPopInputView () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bg_View;
@property (weak, nonatomic) CAGradientLayer* gradientLayer;

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *atButton;
@property (weak, nonatomic) IBOutlet UIButton *emojiButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardingButton;
@property (weak, nonatomic) IBOutlet UILabel *tipTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

/** autoLayout */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *atButton_left_padding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emjioButton_left_padding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forwardingButton_left_padding;

@end

@implementation OSCPopInputView

@synthesize autoSaveDraftNote = _isAutoSaveDraftNote;

- (void)awakeFromNib{
    [super awakeFromNib];
    
    /** layout setting*/
    _inputTextView.text = nil;
    _inputTextView.delegate  = self;
    _inputTextView.returnKeyType = UIReturnKeyNext;
    
    _forwardingButton.hidden = YES;//暂时性隐藏
    
    _tipTextLabel.hidden = YES;
    _sendButton.enabled = YES;

    /** UI display setting*/
    _inputTextView.layer.borderWidth = 1;
    _inputTextView.layer.borderColor = [UIColor colorWithHex:0xc7c7cc].CGColor;
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = 3;
    
    [_sendButton setBackgroundImage:[Utils createImageWithColor:[UIColor colorWithHex:0x24CF5F]] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[Utils createImageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
}

+ (instancetype)popInputViewWithFrame:(CGRect)frame
                      maxStringLenght:(NSInteger)maxStringLenght
                             delegate:(id<OSCPopInputViewDelegate>)delegate
                    autoSaveDraftNote:(BOOL)isAutoSaveDraftNote
{
    OSCPopInputView* popInputView = [[[NSBundle mainBundle] loadNibNamed:@"OSCPopInputView" owner:nil options:nil] lastObject];
    popInputView.frame = frame;
    popInputView.maxStringLenght = maxStringLenght == NSNotFound ? defaultMaxStringLenght : maxStringLenght;
    popInputView.delegate = delegate;
    popInputView.autoSaveDraftNote = isAutoSaveDraftNote;
    return popInputView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isAutoSaveDraftNote = YES;
        _maxStringLenght = defaultMaxStringLenght;
    }
    return self;
}


- (void)activateInputView{
    [self.bg_View.layer addSublayer:self.gradientLayer];
    
    [_inputTextView becomeFirstResponder];
    
    if (_isAutoSaveDraftNote) {
        NSMutableDictionary* draftDic = [self draftNoteDic];
        NSArray* keys = [draftDic allKeys];
        if (_draftKeyID && _draftKeyID.length > 0) {
            if (![keys containsObject:_draftKeyID]) {
                [draftDic setValue:@"" forKey:_draftKeyID];
            }else{
                NSString* draftStr = [draftDic valueForKey:_draftKeyID];
                _inputTextView.text = draftStr;
                [self updateInputViewStatus:_inputTextView.text];
            }
        }
    }
    
    if ([_delegate respondsToSelector:@selector(popInputViewDidShow:)]) {
        [_delegate popInputViewDidShow:self];
    }
}
- (void)freezeInputView{
    [self updateDraftNote:_inputTextView.text];
    [_inputTextView resignFirstResponder];
    
    if ([_delegate respondsToSelector:@selector(popInputViewDidDismiss:draftNoteStr:)]) {
        [_delegate popInputViewDidDismiss:self draftNoteStr:_inputTextView.text];
    }
    if ([_delegate respondsToSelector:@selector(popInputViewDidDismiss:draftNoteAttribute:)]) {
        [_delegate popInputViewDidDismiss:self draftNoteAttribute:_inputTextView.attributedText];
    }
    
    [self.gradientLayer removeFromSuperlayer];
}
- (void)clearDraftNote{
    _inputTextView.attributedText = nil;
    _inputTextView.text = @"";
    NSMutableDictionary* draftDic = [self draftNoteDic];
    if (_draftKeyID && _draftKeyID.length > 0) {
        [draftDic removeObjectForKey:_draftKeyID];
    }
}
- (void)restoreDraftNote:(NSString* )draftNote{
    _inputTextView.text = draftNote;
    [self updateInputViewStatus:draftNote];
    [self updateDraftNote:draftNote];
}
- (void)restoreDraftAttbriteNote:(NSAttributedString* )attributedDraftNote{
    _inputTextView.attributedText = attributedDraftNote;
    [self updateInputViewStatus:attributedDraftNote.string];
}

- (void)restoreDraftNoteWithAttribute:(NSAttributedString *)draftNoteAttribute{
    _inputTextView.attributedText = draftNoteAttribute;
}

- (void)insertAtrributeString:(NSTextAttachment *)textAttachment{
    NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:_inputTextView.attributedText];
    [mutableAttributeString replaceCharactersInRange:_inputTextView.selectedRange withAttributedString:emojiAttributedString];
    _inputTextView.attributedText = mutableAttributeString;
    _inputTextView.textColor = [UIColor titleColor];
    [_inputTextView insertText:@""];
    _inputTextView.font = [UIFont systemFontOfSize:15.0];
}

- (void)deleteClick{
    [_inputTextView deleteBackward];
}

- (void)beginEditing{
    [_inputTextView becomeFirstResponder];
}

- (void)endEditing{
    [_inputTextView resignFirstResponder];
}

#pragma mark - set Method
- (void)setPopInputViewType:(OSCPopInputViewType)popInputViewType{
    _popInputViewType = popInputViewType;
    
    
    if (popInputViewType & OSCPopInputViewType_At) {
        _atButton.hidden = NO;
    }else{
        _atButton.hidden = YES;
    }
    
    if (popInputViewType & OSCPopInputViewType_Emoji) {
        _emojiButton.hidden = NO;
        _emjioButton_left_padding.constant = _atButton.isHidden ? atButton_left_padding_default : emjioButton_left_padding_default;
    }else{
        _emojiButton.hidden = YES;
    }
    
    if (popInputViewType & OSCPopInputViewType_Forwarding) {
        _forwardingButton.hidden = NO;
        _forwardingButton_left_padding.constant = _atButton.isHidden ? (_emojiButton.isHidden ? atButton_left_padding_default : emjioButton_left_padding_default) : (_emojiButton.isHidden ? emjioButton_left_padding_default : forwardingButton_left_padding_default);
    }else{
        _forwardingButton.hidden = YES;
    }
}

- (void)setAutoSaveDraftNote:(BOOL)autoSaveDraftNote{
    _isAutoSaveDraftNote = autoSaveDraftNote;
}

- (void)setMaxStringLenght:(NSInteger)maxStringLenght{
    _maxStringLenght = maxStringLenght;
}

- (void)setDraftKeyID:(NSString *)draftKeyID{
    _draftKeyID = draftKeyID;
    
    if (_isAutoSaveDraftNote) {
        NSMutableDictionary* draftDic = [self draftNoteDic];
        NSArray* keys = [draftDic allKeys];
        if (![keys containsObject:draftKeyID]) {
            [draftDic setValue:@"" forKey:draftKeyID];
        }else{
            NSString* draftStr = [draftDic valueForKey:draftKeyID];
            _inputTextView.text = draftStr;
            [self updateInputViewStatus:_inputTextView.text];
        }
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self updateInputViewStatus:textView.text];
    if (textView.text.length > _maxStringLenght) {
        return NO;
    }else{
        return YES;
    }
}
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > _maxStringLenght) {
        NSRange range = NSMakeRange(0, _maxStringLenght);
        NSString *string = [textView.text substringWithRange:range];
        textView.text = string;
    }
    [self updateInputViewStatus:textView.text];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    [self updateDraftNote:textView.text];
}

#pragma mark - button method
- (IBAction)didClickAtButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(popInputViewClickDidAtButton:)]) {
        [_delegate popInputViewClickDidAtButton:self];
    }
}
- (IBAction)didClickEmojiButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(popInputViewClickDidEmojiButton:)]) {
        [_delegate popInputViewClickDidEmojiButton:self];
    }
}
- (IBAction)didClickForwardingButton:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)didClickSendButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(popInputViewClickDidSendButton:selectedforwarding:curTextView:)]) {
        [_delegate popInputViewClickDidSendButton:self selectedforwarding:_forwardingButton.selected curTextView:_inputTextView];
    }
}


#pragma mark change subViews status
- (void)updateInputViewStatus:(NSString* )str{
    if (str.length >= _maxStringLenght) {
        _tipTextLabel.text = [NSString stringWithFormat:@"此处最多输入%ld字",(long)_maxStringLenght];
        _tipTextLabel.hidden = NO;
        _sendButton.enabled = NO;
    }else{
        _tipTextLabel.hidden = YES;
        _sendButton.enabled = YES;
    }
}
- (void)updateDraftNote:(NSString* )str{
    if (_isAutoSaveDraftNote) {
        if (_draftKeyID && _draftKeyID.length > 0) {
            NSMutableDictionary* draftDic = [self draftNoteDic];
            if (str && str.length > 0) {
                [draftDic setValue:str forKey:_draftKeyID];
            }else{
                [draftDic setValue:@"" forKey:_draftKeyID];
            }
        }
    }
}

#pragma mark draftNoteDic
static NSMutableDictionary* _draftNoteDic;
- (NSMutableDictionary* )draftNoteDic{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _draftNoteDic = @{}.mutableCopy;
    });
    return _draftNoteDic;
}

#pragma mark - lazy loading
- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        CAGradientLayer* gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint   = CGPointMake(0, 1);
        
        gradientLayer.colors = @[
                                 (__bridge id)[[UIColor colorWithHex:0xFFFFFF] colorWithAlphaComponent:0.5].CGColor,
                                 (__bridge id)[[UIColor colorWithHex:0xD1D5DB] colorWithAlphaComponent:0.7].CGColor
                                 ];
        gradientLayer.locations = @[@(0.5f) ,@(1.0f)];
        _gradientLayer = gradientLayer;
    }
    return _gradientLayer;
}
@end









