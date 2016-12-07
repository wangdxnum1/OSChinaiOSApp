//
//  OSCPrivateChatCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChatCell.h"
#import "OSCPrivateChat.h"
#import "ImageDownloadHandle.h"
#import "OSCPhotoGroupView.h"
#import "Utils.h"
#import "UIImageView+CornerRadius.h"
#import <UIImageView+WebCache.h>

#import <YYKit.h>

@interface PrivateChatNodeView : UIView

@property (nonatomic,strong) NSDate* lastUpdateTime;

- (void)handleTimeLabel:(UILabel* )timeLabel;

- (UIImage* )selfPopImage;

- (UIImage* )otherPopImage;

- (UIImage* )imageTip;//单帧图片占位

- (NSArray<UIImage* >* )images;//动画帧图片占位

- (UIImage* )fileTipImage;

@end

@implementation PrivateChatNodeView

- (void)handleTimeLabel:(UILabel *)timeLabel{
    timeLabel.font = [UIFont systemFontOfSize:CHAT_TIME_FONT_SIZE];
    timeLabel.textColor = CHAT_TIME_COLOR;
}

//image source...
static UIImage* _selfPopImage;
- (UIImage *)selfPopImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _selfPopImage = [UIImage imageNamed:@"bg_balloon_right"];
    });
    return _selfPopImage;
}
static UIImage* _otherPopImage;
- (UIImage *)otherPopImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _otherPopImage = [UIImage imageNamed:@"bg_balloon_left"];
    });
    return _otherPopImage;
}
static UIImage* _imageTip;
- (UIImage *)imageTip{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _imageTip = [UIImage imageNamed:@"loading_1"];
    });
    return _imageTip;
}
static NSArray<UIImage* >* _images;
- (NSArray<UIImage *> *)images{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _images = @[
                    [UIImage imageNamed:@"loading_1"],
                    [UIImage imageNamed:@"loading_2"],
                    [UIImage imageNamed:@"loading_3"]
                    ];
    });
    return _images;
}
static UIImage* _fileTipImage;
- (UIImage *)fileTipImage{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileTipImage = [UIImage imageNamed:@"ic_pm_file"];
    });
    return _fileTipImage;
}
@end

#pragma mark --- 文本类型
@interface PrivateChatNodeTextView : PrivateChatNodeView <UITextViewDelegate>
{
    __weak UIImageView* _popImageView;
    __weak UITextView* _textView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@property (nonatomic,weak) OSCPrivateChatCell* privateChatCell;

@end

@implementation PrivateChatNodeTextView{
    CGRect _popFrame,_textFrame,_timeTipFrame;
    CGFloat _rowHeight;
    BOOL _isSelf;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView* popImageView = [UIImageView new];
            _popImageView = popImageView;
            _popImageView;
        })];
        [self addSubview:({
            UITextView* textView = [UITextView new];
            _textView = textView;
            _textView.delegate = self;
            _textView.backgroundColor = [UIColor clearColor];
            _textView.font = [UIFont systemFontOfSize:CHAT_TEXT_FONT_SIZE];
            _textView.editable = NO;
            _textView.scrollEnabled = NO;
            [_textView setTextContainerInset:UIEdgeInsetsZero];
            _textView.textContainer.lineFragmentPadding = 0;
            [_textView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
            _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
            [_textView setTextAlignment:NSTextAlignmentLeft];
            _textView.text = @" ";
            _textView;
        })];
        [self addSubview:({
            UILabel* timeLabel = [UILabel new];
            _timeLabel = timeLabel;
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self handleTimeLabel:_timeLabel];
            _timeLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize popSize = _popFrame.size;
    CGSize textSize = _textFrame.size;
    CGSize timeSize = _timeTipFrame.size;
    if (_isSelf) {
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        if (_privateChatItem.isDisplayTimeTip) { popFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _popFrame = popFrame;
        CGRect textFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_PADDING_RIGHT - textSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP,textSize};
        if (_privateChatItem.isDisplayTimeTip) { textFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _textFrame = textFrame;
        
        if (_privateChatItem.isDisplayTimeTip) {
            _timeLabel.frame = (CGRect){{0,5},timeSize};
        }
    }else{
        CGRect popFrame = (CGRect){{SCREEN_PADDING_LEFT,SCREEN_PADDING_TOP},popSize};
        if (_privateChatItem.isDisplayTimeTip) { popFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _popFrame = popFrame;
        CGRect textFrame = (CGRect){{SCREEN_PADDING_LEFT + PRIVATE_POP_PADDING_LEFT,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP},textSize};
        if (_privateChatItem.isDisplayTimeTip) { textFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _textFrame = textFrame;

        if (_privateChatItem.isDisplayTimeTip) {
            _timeLabel.frame = (CGRect){{0,5},timeSize};
        }
    }
    
    _popImageView.frame = _popFrame;
    _textView.frame = _textFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    _isSelf = privateChatItem.sender.isBySelf;

    if (_isSelf) {
        [_popImageView setImage:[self selfPopImage]];
        _textView.attributedText = [Utils contentStringFromRawString:privateChatItem.content privateChatType:YES];
    }else{
        [_popImageView setImage:[self otherPopImage]];
        _textView.attributedText = [Utils contentStringFromRawString:privateChatItem.content privateChatType:NO];
    }

    
    if (privateChatItem.isDisplayTimeTip) {
        _timeLabel.hidden = NO;
        _timeLabel.text = [privateChatItem.pubDate substringWithRange:NSMakeRange(0, 16)];
    }else{
        _timeLabel.hidden = YES;
    }
    
    _popFrame = privateChatItem.popFrame;
    _textFrame = privateChatItem.textFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
    self.height = _rowHeight;
}

//长按处理
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}
- (void)copy:(id)sender{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_textView.text];
}

#pragma mark --- UITextView delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([self.privateChatCell.delegate respondsToSelector:@selector(privateChatNodeTextViewshouldInteractTextView:URL:inRange:)]) {
        [self.privateChatCell.delegate privateChatNodeTextViewshouldInteractTextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}
@end



#pragma mark --- 图片类型

#define MAX_IMAGE_SIZE_W PRIVATE_MAX_WIDTH

@interface PrivateChatNodeImageView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _photoView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@property (nonatomic,weak) OSCPrivateChatCell* privateChatCell;

@end

@implementation PrivateChatNodeImageView{
    CGRect _popFrame,_imageFrame,_timeTipFrame;
    CGFloat _rowHeight;
    BOOL _isSelf;
    BOOL _trackingTouch_PhotoImageView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView* popImageView = [UIImageView new];
            _popImageView = popImageView;
            _popImageView;
        })];
        [self addSubview:({
            UIImageView* photoView = [UIImageView new];
            _photoView = photoView;
//            _photoView.contentMode = UIViewContentModeCenter;
            [_photoView zy_cornerRadiusAdvance:10 rectCornerType:UIRectCornerAllCorners];
            _photoView;
        })];
        [self addSubview:({
            UILabel* timeLabel = [UILabel new];
            _timeLabel = timeLabel;
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self handleTimeLabel:_timeLabel];
            _timeLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize popSize = _popFrame.size;
    CGSize imageSize = _imageFrame.size;
    CGSize timeSize = _timeTipFrame.size;
    
    if (_isSelf){
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        if (_privateChatItem.isDisplayTimeTip) { popFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _popFrame = popFrame;
        CGRect imageFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_IMAGE_PADDING_RIGHT - imageSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_IMAGE_PADDING_TOP,imageSize};
        if (_privateChatItem.isDisplayTimeTip) { imageFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _imageFrame = imageFrame;
        
        if (_privateChatItem.isDisplayTimeTip) {
            _timeLabel.frame = (CGRect){{0,5},timeSize};
        }
    }else{
        CGRect popFrame = (CGRect){{SCREEN_PADDING_LEFT,SCREEN_PADDING_TOP},popSize};
        if (_privateChatItem.isDisplayTimeTip) { popFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _popFrame = popFrame;
        CGRect imageFrame = (CGRect){{SCREEN_PADDING_LEFT + PRIVATE_POP_IMAGE_PADDING_LEFT,SCREEN_PADDING_TOP + PRIVATE_POP_IMAGE_PADDING_TOP},imageSize};
        if (_privateChatItem.isDisplayTimeTip) { imageFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _imageFrame = imageFrame;

        if (_privateChatItem.isDisplayTimeTip) {
            _timeLabel.frame = (CGRect){{0,5},timeSize};
        }
    }
    
    _popImageView.frame = _popFrame;
    _photoView.frame = _imageFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    _isSelf = privateChatItem.sender.isBySelf;;
    
    if (_isSelf) {
        [_popImageView setImage:[self selfPopImage]];
    }else{
        [_popImageView setImage:[self otherPopImage]];
    }
    
    if (privateChatItem.isDisplayTimeTip) {
        _timeLabel.hidden = NO;
        _timeLabel.text = [privateChatItem.pubDate substringWithRange:NSMakeRange(0, 16)];
    }else{
        _timeLabel.hidden = YES;
    }

    UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:privateChatItem.resource];
    if (!image) {
//        _photoView.image = [self imageTip];
        _photoView.animationImages = [self images];
        _photoView.animationRepeatCount = 0;
        _photoView.animationDuration = 1.0;
        [_photoView startAnimating];
        
        __weak typeof(self) weakSelf = self;
        [_photoView sd_setImageWithURL:[NSURL URLWithString:privateChatItem.resource]
                      placeholderImage:nil options:SDWebImageContinueInBackground | SDWebImageHandleCookies
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGSize resultSize = [weakSelf adjustImage:image];
            privateChatItem.imageFrame = (CGRect){{0,0},resultSize};
            privateChatItem.popFrame = (CGRect){{0,0},{resultSize.width + PRIVATE_POP_IMAGE_PADDING_LEFT + PRIVATE_POP_IMAGE_PADDING_RIGHT , resultSize.height + PRIVATE_POP_IMAGE_PADDING_TOP + PRIVATE_POP_IMAGE_PADDING_BOTTOM}};
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_privateChatCell.delegate respondsToSelector:@selector(privateChatNodeImageViewloadThumbImageDidFinsh:)]) {
                    [_privateChatCell.delegate privateChatNodeImageViewloadThumbImageDidFinsh:_privateChatCell];
                }
            });
        }];
    }else{
        _photoView.animationImages = nil;
        
        _photoView.image = image;
        CGSize resultSize = [self adjustImage:image];
        privateChatItem.imageFrame = (CGRect){{0,0},resultSize};
        privateChatItem.popFrame = (CGRect){{0,0},{resultSize.width + PRIVATE_POP_IMAGE_PADDING_LEFT + PRIVATE_POP_IMAGE_PADDING_RIGHT , resultSize.height + PRIVATE_POP_IMAGE_PADDING_TOP + PRIVATE_POP_IMAGE_PADDING_BOTTOM}};
    }
    
    _popFrame = privateChatItem.popFrame;
    _imageFrame = privateChatItem.imageFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
    self.height = _rowHeight;
}

#pragma mark --- 图片大小 & 遮罩处理
- (CGSize)adjustImage:(UIImage* )image{
    if (!image) {return CGSizeZero;}
    CGSize resultSize ;
    if (image.size.width > MAX_IMAGE_SIZE_W) {
        resultSize = (CGSize){MAX_IMAGE_SIZE_W,(MAX_IMAGE_SIZE_W * image.size.height) / image.size.width};
    }else{
        resultSize = image.size;
    }
    return resultSize;
}
- (void)maskView:(UIView *)view image:(UIImage *)image {
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0, 0);
    
    view.layer.mask = imageViewMask.layer;
}
#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_PhotoImageView = NO;
    UITouch* t = [touches anyObject];
    CGPoint p = [t locationInView:_photoView];
    if (CGRectContainsPoint(_photoView.bounds, p)) {
        _trackingTouch_PhotoImageView = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_PhotoImageView) {
        UIImageView* fromView = _photoView;
        
        OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
        currentPhotoItem.largeImageURL = [NSURL URLWithString:_privateChatItem.resource];
        currentPhotoItem.thumbView = fromView;
        
        OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
        if ([_privateChatCell.delegate respondsToSelector:@selector(privateChatNodeImageViewloadLargerImageDidFinsh:photoGroupView:fromView:)]) {
            [_privateChatCell.delegate privateChatNodeImageViewloadLargerImageDidFinsh:_privateChatCell photoGroupView:photoGroup fromView:fromView];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_PhotoImageView) {
        [super touchesCancelled:touches withEvent:event];
    }
}
@end



#pragma mark --- 文件类型
@interface PrivateChatNodeFileView : PrivateChatNodeView{
    __weak UIImageView* _popImageView;
    __weak UIImageView* _fileTipView;
    __weak UILabel* _timeLabel;
}

@property (nonatomic,strong) OSCPrivateChat* privateChatItem;

@property (nonatomic,weak) OSCPrivateChatCell* privateChatCell;

@end

@implementation PrivateChatNodeFileView{
    CGRect _popFrame,_fileFrame,_timeTipFrame;
    CGFloat _rowHeight;
    BOOL _isSelf;
    BOOL _trackingTouch_FileView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            UIImageView* popImageView = [UIImageView new];
            _popImageView = popImageView;
            _popImageView;
        })];
        [self addSubview:({
            UIImageView* fileTipView = [UIImageView new];
            _fileTipView = fileTipView;
            _fileTipView.image = [self fileTipImage];
            _fileTipView;
        })];
        [self addSubview:({
            UILabel* timeLabel = [UILabel new];
            _timeLabel = timeLabel;
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self handleTimeLabel:_timeLabel];
            _timeLabel;
        })];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize popSize = _popFrame.size;
    CGSize fileSize = _fileFrame.size;
    CGSize timeSize = _timeTipFrame.size;
    
    if (_isSelf) {
        CGRect popFrame = (CGRect){{kScreen_Width - SCREEN_PADDING_RIGHT - popSize.width,SCREEN_PADDING_TOP},popSize};
        if (_privateChatItem.isDisplayTimeTip) { popFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _popFrame = popFrame;
        CGRect fileFrame = (CGRect){kScreen_Width - SCREEN_PADDING_RIGHT - PRIVATE_POP_PADDING_RIGHT - fileSize.width,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP,fileSize};
        if (_privateChatItem.isDisplayTimeTip) { fileFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _fileFrame = fileFrame;
        
        if (_privateChatItem.isDisplayTimeTip) {
            _timeLabel.frame = (CGRect){{0,5},timeSize};
        }
    }else{
        CGRect popFrame = (CGRect){{SCREEN_PADDING_LEFT,SCREEN_PADDING_TOP},popSize};
        if (_privateChatItem.isDisplayTimeTip) { popFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _popFrame = popFrame;
        CGRect fileFrame = (CGRect){{SCREEN_PADDING_LEFT + PRIVATE_POP_PADDING_LEFT,SCREEN_PADDING_TOP + PRIVATE_POP_PADDING_TOP},fileSize};
        if (_privateChatItem.isDisplayTimeTip) { fileFrame.origin.y += PRIVATE_TIME_TIP_ADDITIONAL; }
        _fileFrame = fileFrame;

        if (_privateChatItem.isDisplayTimeTip) {
            _timeLabel.frame = (CGRect){{0,5},timeSize};
        }
    }
    
    _popImageView.frame = _popFrame;
    _fileTipView.frame = _fileFrame;
}

- (void)setPrivateChatItem:(OSCPrivateChat *)privateChatItem{
    _privateChatItem = privateChatItem;
    
    _isSelf = privateChatItem.sender.isBySelf;
    if (_isSelf) {
        [_popImageView setImage:[self selfPopImage]];
    }else{
        [_popImageView setImage:[self otherPopImage]];
    }
    
    if (privateChatItem.isDisplayTimeTip) {
        _timeLabel.hidden = NO;
        _timeLabel.text = [privateChatItem.pubDate substringWithRange:NSMakeRange(0, 16)];
    }else{
        _timeLabel.hidden = YES;
    }
    
    _popFrame = privateChatItem.popFrame;
    _fileFrame = privateChatItem.fileFrame;
    _timeTipFrame = privateChatItem.timeTipFrame;
    _rowHeight = privateChatItem.rowHeight;
    self.height = _rowHeight;
}

#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_FileView = NO;
    UITouch* t = [touches anyObject];
    CGPoint p_1 = [t locationInView:_popImageView];
    CGPoint p_2 = [t locationInView:_fileTipView];
    if (CGRectContainsPoint(_popImageView.bounds,p_1) || CGRectContainsPoint(_fileTipView.bounds, p_2)) {
        _trackingTouch_FileView = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_FileView) {
        if ([self.privateChatCell.delegate respondsToSelector:@selector(privateChatNodeFileViewDidClickFile:)]) {
            [self.privateChatCell.delegate privateChatNodeFileViewDidClickFile:self.privateChatCell];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_trackingTouch_FileView) {
        [super touchesCancelled:touches withEvent:event];
    }
}
@end

























@interface OSCPrivateChatCell ()
@property (nonatomic,weak) PrivateChatNodeTextView* textChatView;
@property (nonatomic,weak) PrivateChatNodeImageView* imageChatView;
@property (nonatomic,weak) PrivateChatNodeFileView* fileChatView;
@end

@implementation OSCPrivateChatCell

+ (instancetype)returnReusePrivateChatCellWithTableView:(UITableView *)tableView
                                             identifier:(NSString *)identifier
{
    OSCPrivateChatCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[OSCPrivateChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setPrivateChat:(OSCPrivateChat *)privateChat{
    if (!privateChat || _privateChat == privateChat) { return; }
    
    _privateChat = privateChat;

    [self _removeContentView];
    
    switch (_privateChat.privateChatType) {
        case OSCPrivateChatTypeText:{
            PrivateChatNodeTextView* textNodeView = [[PrivateChatNodeTextView alloc]initWithFrame:self.contentView.bounds];
            textNodeView.privateChatCell = self;
            [self.contentView addSubview:textNodeView];
            textNodeView.privateChatItem = _privateChat;
            
//            [self.contentView addSubview:self.textChatView];
//            self.textChatView.privateChatCell = self;
//            self.textChatView.privateChatItem = _privateChat;
            break;
        }
        case OSCPrivateChatTypeImage:{
            PrivateChatNodeImageView* imageNodeView = [[PrivateChatNodeImageView alloc]initWithFrame:self.contentView.bounds];
            imageNodeView.privateChatCell = self;
            [self.contentView addSubview:imageNodeView];
            imageNodeView.privateChatItem = _privateChat;
            
//            [self.contentView addSubview:self.imageChatView];
//            self.imageChatView.privateChatCell = self;
//            self.imageChatView.privateChatItem = _privateChat;
            break;
        }
        case OSCPrivateChatTypeFile:{
            PrivateChatNodeFileView* fileNodeView = [[PrivateChatNodeFileView alloc]initWithFrame:self.contentView.bounds];
            fileNodeView.privateChatCell = self;
            [self.contentView addSubview:fileNodeView];
            fileNodeView.privateChatItem = _privateChat;
            
//            [self.contentView addSubview:self.fileChatView];
//            self.fileChatView.privateChatCell = self;
//            self.fileChatView.privateChatItem = _privateChat;
            break;
        }
        default:
            NSLog(@"privateChatType is NSNotFound");
            break;
    }
}

- (void)_removeContentView{
    for (UIView* view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
}

#pragma mark --- lazy loading
- (PrivateChatNodeTextView *)textChatView {
    if(_textChatView == nil) {
        PrivateChatNodeTextView* textChatView = [[PrivateChatNodeTextView alloc] initWithFrame:self.contentView.bounds];
        _textChatView = textChatView;
    }
    return _textChatView;
}
- (PrivateChatNodeImageView *)imageChatView {
    if(_imageChatView == nil) {
        PrivateChatNodeImageView* imageChatView = [[PrivateChatNodeImageView alloc] initWithFrame:self.contentView.bounds];
        _imageChatView = imageChatView;
    }
    return _imageChatView;
}
- (PrivateChatNodeFileView *)fileChatView {
    if(_fileChatView == nil) {
        PrivateChatNodeFileView* fileChatView = [[PrivateChatNodeFileView alloc] initWithFrame:self.contentView.bounds];
        _fileChatView = fileChatView;
    }
    return _fileChatView;
}
@end








