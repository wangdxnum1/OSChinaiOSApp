//
//  MessageBubbleCell.m
//  iosapp
//
//  Created by ChanAetern on 2/12/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "MessageBubbleCell.h"
#import "Utils.h"

static const int othersBubbleColor = 0x15A230;
static const int myBubbleColor     = 0xC7C7C7;

@interface MessageBubbleCell ()

@property (nonatomic, assign) BOOL isMine;

@property (nonatomic, strong) UITextView *messageView;

@property (nonatomic, strong) UIImageView *bubble;
@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthConstraint;

@end

@implementation MessageBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (reuseIdentifier == kMessageBubbleMe) {
            _isMine = YES;
        } else {
            _isMine = NO;
        }
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    [_portrait setCornerRadius:18];
    _portrait.userInteractionEnabled = YES;
    [self.contentView addSubview:_portrait];
    
    
    _messageView = [UITextView new];
    _messageView.editable = NO;
    _messageView.scrollEnabled = NO;
    _messageView.backgroundColor = [UIColor clearColor];
    _messageView.font = [UIFont systemFontOfSize:15];
    _messageView.selectable = NO;
    _messageView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
    
    
    UIImage *bubbleImage = [UIImage imageNamed:@"bubble"];
    if (_isMine) {
        bubbleImage = [bubbleImage imageMaskedWithColor:[UIColor colorWithHex:myBubbleColor]];
    } else {
        bubbleImage = [bubbleImage imageMaskedWithColor:[UIColor colorWithHex:othersBubbleColor]];
        bubbleImage = [self jsq_horizontallyFlippedImageFromImage:bubbleImage];
        
        _messageView.textColor = [UIColor colorWithHex:0xE1E1E1];
    }
    bubbleImage = [bubbleImage resizableImageWithCapInsets:[self jsq_centerPointEdgeInsetsForImageSize:bubbleImage.size]
                                              resizingMode:UIImageResizingModeStretch];
    
    _bubble = [UIImageView new];
    _bubble.image = bubbleImage;
    _bubble.userInteractionEnabled = YES;
    [self.contentView addSubview:_bubble];
    [_bubble addSubview:_messageView];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    _messageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _bubble, _messageView);
    
    NSLayoutFormatOptions option = _isMine? NSLayoutFormatDirectionRightToLeft : 0;
    NSDictionary *metrics = @{@"leading": @(15), @"tailing": @(10)};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(36)]" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_bubble]-8-|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_bubble]"
                                                                             options:NSLayoutFormatAlignAllBottom | option
                                                                             metrics:nil views:views]];
    
    [_bubble addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_messageView]|" options:0 metrics:nil views:views]];
    [_bubble addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-leading-[_messageView]-tailing-|" options:option metrics:metrics views:views]];
    
    
    _bubbleWidthConstraint = [NSLayoutConstraint constraintWithItem:_bubble attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                             toItem:nil     attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:25];
    
    [self.contentView addConstraint:_bubbleWidthConstraint];
}


- (UIImage *)jsq_horizontallyFlippedImageFromImage:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}


- (UIEdgeInsets)jsq_centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize
{
    CGPoint center = CGPointMake(bubbleImageSize.width / 2.0f, bubbleImageSize.height / 2.0f);
    return UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
}


- (void)setContent:(NSString *)content andPortrait:(NSURL *)portraitURL
{
    _messageView.text = content;
    [_portrait loadPortrait:portraitURL];
    
    
    CGFloat bubbleWidth = [_messageView sizeThatFits:CGSizeMake(self.contentView.frame.size.width-85, MAXFLOAT)].width;
    
    _bubbleWidthConstraint.constant = bubbleWidth + 25;
    [self.contentView setNeedsUpdateConstraints];
    [self.contentView layoutIfNeeded];
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
    [pasteBoard setString:_messageView.text];
}

- (void)deleteObject:(id)sender
{
    _deleteObject(self);
}


@end
