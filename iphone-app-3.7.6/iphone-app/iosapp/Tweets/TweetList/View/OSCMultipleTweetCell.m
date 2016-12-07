//
//  OSCMultipleTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMultipleTweetCell.h"
#import "OSCTweetItem.h"
#import "OSCPhotoGroupView.h"
#import "UIImageView+RadiusHandle.h"
#import "ImageDownloadHandle.h"
#import "UIColor+Util.h"
#import "Utils.h"
#import <UIImage+GIF.h>

#import <YYKit.h>

@interface OSCMultipleTweetCell ()<UITextViewDelegate>{
    NSMutableArray* _imageViewsArray;   //二维数组 _imageViewsArray[line][row]
    NSMutableArray<OSCTweetImages* >* _largerImageUrls;   //本地维护的大图数组
    NSMutableArray<UIImageView* >* _visibleImageViews;   //可见的imageView数组
    
    OSCPhotoGroupView* _photoGroup;
    
/** 以下是根据屏幕大小进行适配的宽高值 (在 setSubViews 底部进行维护)*/
    /**
     _multiple_WH  为多图容器的宽高
     _imageItem_WH 为每张图片的宽高
     Multiple_Padding 是容器距离屏幕边缘的padding值
     ImageItemPadding 是多图图片之间的padding值
     */
    CGFloat _multiple_WH;
    CGFloat _imageItem_WH;
    CGFloat Multiple_Padding;
    CGFloat ImageItemPadding;
    
    CGFloat _rowHeight;
    CGSize _descTextViewSize;
    CGSize _imagesContainerViewSize;
    
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_likeBtn;
}
@end

@implementation OSCMultipleTweetCell{
    __weak UIImageView* _userPortrait;
    __weak YYLabel* _nameLabel;
    __weak UITextView* _descTextView;
    
    __weak UIView* _imagesView;
    __weak CALayer* _colorLine;
    
    __weak YYLabel* _timeAndSourceLabel;
    __weak UIImageView* _likeCountButton;
    __weak YYLabel* _likeCountLabel;
    __weak UIImageView* _commentCountBtn;
    __weak YYLabel* _commentCountLabel;
}
+ (instancetype)returnReuseMultipleTweetCellWithTableView:(UITableView *)tableView
                                              identifier:(NSString *)reuseIdentifier
{
    OSCMultipleTweetCell* multipleTweetCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!multipleTweetCell) {
        multipleTweetCell = [[OSCMultipleTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [multipleTweetCell addSubViews];
    }
    return multipleTweetCell;
}

- (void)addSubViews{
    _largerImageUrls = [NSMutableArray arrayWithCapacity:9];
    _visibleImageViews = [NSMutableArray arrayWithCapacity:9];
    
    UIImageView* userPortrait = [UIImageView new];
    _userPortrait = userPortrait;
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    _userPortrait.userInteractionEnabled = YES;
    [_userPortrait handleCornerRadiusWithRadius:22];
//    [_userPortrait zy_cornerRadiusAdvance:22 rectCornerType:UIRectCornerAllCorners];
    [self.contentView addSubview:_userPortrait];
    
    YYLabel* nameLabel = [YYLabel new];
    _nameLabel = nameLabel;
    _nameLabel.font = [UIFont boldSystemFontOfSize:nameLabel_FontSize];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textColor = [UIColor newTitleColor];
    _nameLabel.displaysAsynchronously = YES;
    _nameLabel.fadeOnAsynchronouslyDisplay = NO;
    _nameLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_nameLabel];
    
    UITextView* descTextView = [UITextView new];
    _descTextView = descTextView;
    [_descTextView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forwardingEvent:)]];
    _descTextView.delegate = self;
    [self handleTextView:_descTextView];
    [self.contentView addSubview:_descTextView];
    
    UIView* imagesView = [[UIView alloc]init];
    _imagesView = imagesView;
    [self.contentView addSubview:_imagesView];
    
    YYLabel* timeAndSourceLabel = [YYLabel new];
    _timeAndSourceLabel = timeAndSourceLabel;
    _timeAndSourceLabel.font = [UIFont systemFontOfSize:12];
    _timeAndSourceLabel.displaysAsynchronously = YES;
    _timeAndSourceLabel.fadeOnAsynchronouslyDisplay = NO;
    _timeAndSourceLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_timeAndSourceLabel];
   
    YYLabel* commentCountLabel = [YYLabel new];
    _commentCountLabel = commentCountLabel;
    _commentCountLabel.textAlignment = NSTextAlignmentLeft;
    _commentCountLabel.font = [UIFont systemFontOfSize:12];
    _commentCountLabel.textColor = [UIColor newAssistTextColor];
    _commentCountLabel.displaysAsynchronously = YES;
    _commentCountLabel.fadeOnAsynchronouslyDisplay = NO;
    _commentCountLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_commentCountLabel];
    
    UIImageView* commentCountBtn = [[UIImageView alloc]initWithImage:[self commentImage]];
    _commentCountBtn = commentCountBtn;
    [self.contentView addSubview:_commentCountBtn];
    
    YYLabel* likeCountLabel = [YYLabel new];
    _likeCountLabel = likeCountLabel;
    _likeCountLabel.textAlignment = NSTextAlignmentLeft;
    _likeCountLabel.font = [UIFont systemFontOfSize:12];
    _likeCountLabel.textColor = [UIColor newAssistTextColor];
    _likeCountLabel.displaysAsynchronously = YES;
    _likeCountLabel.fadeOnAsynchronouslyDisplay = NO;
    _likeCountLabel.fadeOnHighlight = NO;
    [self.contentView addSubview:_likeCountLabel];
    
    UIImageView* likeCountButton = [[UIImageView alloc]initWithImage:[self unlikeImage]];
    _likeCountButton = likeCountButton;
    _likeCountButton.contentMode = UIViewContentModeTopRight;
    [self.contentView addSubview:_likeCountButton];
    
    CALayer* colorLine = [CALayer new];
    _colorLine = colorLine;
    _colorLine.backgroundColor = [UIColor separatorColor].CGColor;
    [self.contentView.layer addSublayer:_colorLine];
    
#pragma TODO:: 使用宏代替 multiple_WH & imageItem_WH
    /** 全局padding值*/
    Multiple_Padding = 69;
    ImageItemPadding = 8;
    
    /** 动态值维护*/
    CGFloat multiple_WH = ceil(([UIScreen mainScreen].bounds.size.width - (Multiple_Padding * 2)));
    _multiple_WH = multiple_WH;
    CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
    _imageItem_WH = imageItem_WH;
    
    [self addMultiples];
}

- (void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    for (int i = 0 ; i < 3; i++) {//line
        originY = i * (_imageItem_WH + ImageItemPadding);
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            originX = j * (_imageItem_WH + ImageItemPadding);
            UIImageView* imageView = [[UIImageView alloc]init];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImageWithTap:)]];
            imageView.backgroundColor = [UIColor newCellColor];
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
            imageView.frame = (CGRect){{originX,originY},{_imageItem_WH,_imageItem_WH}};
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imagesView addSubview:imageView];
//            imageTypeLogo
            UIImageView* imageTypeLogo = [UIImageView new];
            imageTypeLogo.userInteractionEnabled = NO;
            imageTypeLogo.hidden = YES;
            [imageView addSubview:imageTypeLogo];
            
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
}

-(void)setTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;
    
    for (OSCTweetImages* imageDataSource in tweetItem.images) {
        [_largerImageUrls addObject:imageDataSource];
    }
    
//    UIImage* portrait = [ImageDownloadHandle retrieveMemoryAndDiskCache:tweetItem.author.portrait];
//    if (!portrait) {
//        _userPortrait.backgroundColor = [UIColor newCellColor];;
//        [ImageDownloadHandle downloadImageWithUrlString:tweetItem.author.portrait SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _userPortrait.userInteractionEnabled = YES;
//                [_userPortrait setImage:image];
//            });
//        }];
//    }else{
//        [_userPortrait setImage:portrait];
//    }
    
    [_userPortrait loadPortrait:[NSURL URLWithString:tweetItem.author.portrait]];

    _nameLabel.text = tweetItem.author.name;
    _descTextView.attributedText = [Utils contentStringFromRawString:tweetItem.content];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:tweetItem.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)tweetItem.appClient]];
    att.color = [UIColor newAssistTextColor];
    _timeAndSourceLabel.attributedText = att;

    if (tweetItem.liked) {
        [_likeCountButton setImage:[self likeImage]];
    } else {
        [_likeCountButton setImage:[self unlikeImage]];
    }
    
    _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetItem.likeCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetItem.commentCount];
 
    _rowHeight = tweetItem.rowHeight;
    _descTextViewSize = tweetItem.descTextFrame.size;
    _imagesContainerViewSize = tweetItem.multipleFrame.frame.size;
    self.contentView.height = _rowHeight;
    
    [self loopAssemblyContentWithLine:tweetItem.multipleFrame.line
                                  row:tweetItem.multipleFrame.row
                                count:(int)tweetItem.images.count];
}

#pragma mark --- 为多图容器赋值
-(void)loopAssemblyContentWithLine:(int)line row:(int)row count:(int)count{
    int dataIndex = 0;
    for (int i = 0; i < line; i++) {
        for (int j = 0; j < row; j++) {
            if (dataIndex == count) return;
            OSCTweetImages* imageData = _tweetItem.images[dataIndex];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.tag = dataIndex;
            imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
            imageView.hidden = NO;
            [_visibleImageViews addObject:imageView];
            
            BOOL isGif = [imageData.thumb hasSuffix:@".gif"];
            if (isGif){
                UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                imageTypeLogo.frame = (CGRect){{imageView.bounds.size.width - 18 - 2,imageView.bounds.size.height - 11 - 2 },{18,11}};
                imageTypeLogo.image = [self gifImage];
                imageTypeLogo.hidden = NO;
            }

            UIImage* largerImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.href];
            
            if (largerImage) {
                if (isGif) {
                    NSData *dataImage = UIImagePNGRepresentation(largerImage);
                    largerImage = [UIImage sd_animatedGIFWithData:dataImage];
                }
                [imageView setImage:largerImage];
                imageView.userInteractionEnabled = YES;
            }else{
                UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.thumb];
                if (!image) {
                    [ImageDownloadHandle downloadImageWithUrlString:imageData.thumb SaveToDisk:YES completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (isGif) {
                                NSData *dataImage = UIImagePNGRepresentation(image);
                                UIImage* gifImage = [UIImage sd_animatedGIFWithData:dataImage];
                                [imageView setImage:gifImage];
                            }else{
                                [imageView setImage:image];
                            }
                            imageView.userInteractionEnabled = YES;
                        });
                    }];
                }else{
                    if (isGif) {
                        NSData *dataImage = UIImagePNGRepresentation(image);
                        image = [UIImage sd_animatedGIFWithData:dataImage];
                    }
                    [imageView setImage:image];
                    imageView.userInteractionEnabled = YES;
                }

            }
            
            dataIndex++;
        }
    }
}

#pragma mark --- 加载大图
- (void)loadLargeImageWithTap:(UITapGestureRecognizer* )tap{
    UIImageView* fromView = (UIImageView* )tap.view;
    int index = (int)fromView.tag;
    //    current touch object
    OSCTweetImages* image =  _largerImageUrls[index];
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.thumbView = fromView;
    currentPhotoItem.largeImageURL = [NSURL URLWithString:image.href];
    currentPhotoItem.largeImageSize = (CGSize){image.w,image.h};
    
    //    all imageItem objects
    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_largerImageUrls.count];
    
    for (int i = 0; i < _largerImageUrls.count; i++) {
        OSCTweetImages* iamges =  _largerImageUrls[i];
        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
        photoItem.thumbView = _visibleImageViews[i];
        photoItem.largeImageURL = [NSURL URLWithString:iamges.href];
        photoItem.largeImageSize = (CGSize){image.w,image.h};
        [photoGroupItems addObject:photoItem];
    }
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];
    
    if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
        [_delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _userPortrait.size = (CGSize){userPortrait_W,userPortrait_H};
    _userPortrait.left = padding_left;
    _userPortrait.top = padding_top;
    
    _nameLabel.top = padding_top;
    _nameLabel.left = CGRectGetMaxX(_userPortrait.frame) + userPortrait_SPACE_nameLabel;
    _nameLabel.width = kScreen_W - padding_right - (CGRectGetMaxX(_userPortrait.frame) + userPortrait_SPACE_nameLabel);
    _nameLabel.height = nameLabel_H;
    
    _descTextView.left = CGRectGetMaxX(_userPortrait.frame) + descTextView_SPACE_userPortrait;
    _descTextView.top = CGRectGetMaxY(_nameLabel.frame) + nameLabel_space_descTextView;
    _descTextView.size = _descTextViewSize;
    
    _imagesView.left = _descTextView.left;
    _imagesView.top = _descTextView.bottom + descTextView_space_imageView;
    _imagesView.size = _imagesContainerViewSize;
    
    _timeAndSourceLabel.left = _descTextView.left;
    _timeAndSourceLabel.top = CGRectGetMaxY(_imagesView.frame) + imageView_space_timeAndSourceLabel;
    _timeAndSourceLabel.size = (CGSize){timeAndSourceLabel_W,timeAndSourceLabel_H};
    
    _commentCountLabel.size = (CGSize){commentCountLabel_W,commentCountLabel_H};
    _commentCountLabel.left = kScreen_W - _commentCountLabel.width - padding_right + 14;
    _commentCountLabel.top = _timeAndSourceLabel.top;
    
    _commentCountBtn.size = (CGSize){operationBtn_W,operationBtn_H};
    _commentCountBtn.top = _timeAndSourceLabel.top;
    _commentCountBtn.left = CGRectGetMinX(_commentCountLabel.frame) - operationBtn_space_label - _commentCountBtn.width;
    
    _likeCountLabel.size = (CGSize){commentCountLabel_W,commentCountLabel_H };
    _likeCountLabel.top = _timeAndSourceLabel.top;
    _likeCountLabel.left = CGRectGetMinX(_commentCountBtn.frame) - like_space_comment - _likeCountLabel.width;
    
    _likeCountButton.size = (CGSize){operationBtn_W + 10,operationBtn_H + 10};
    _likeCountButton.top = _timeAndSourceLabel.top - 1;
    _likeCountButton.left = CGRectGetMinX(_likeCountLabel.frame) - operationBtn_space_label - _likeCountButton.width;
    
    _colorLine.left = _userPortrait.left;
    _colorLine.top = _rowHeight - separatorLine_H;
    _colorLine.width = kScreen_W - padding_left;
    _colorLine.height = separatorLine_H;
}

#pragma mark - prepare for reuse
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _userPortrait.image = nil;
    
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.backgroundColor = [UIColor newCellColor];
            imageView.userInteractionEnabled = NO;
            imageView.tag = 0;
            imageView.hidden = YES;
            imageView.image = nil;
            [_largerImageUrls removeAllObjects];
            [_visibleImageViews removeAllObjects];
            _photoGroup = nil;
            UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
            imageTypeLogo.image = nil;
            imageTypeLogo.hidden = YES;
        }
    }
}

#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    _trackingTouch_likeBtn = NO;
    UITouch *t = touches.anyObject;
    CGPoint p1 = [t locationInView:_userPortrait];
    CGPoint p2 = [t locationInView:_likeCountButton];
    CGPoint p2_1 = [t locationInView:_likeCountLabel];
    if (CGRectContainsPoint(_userPortrait.bounds, p1)) {
        _trackingTouch_userPortrait = YES;
    }else if(CGRectContainsPoint(_likeCountButton.bounds, p2) || CGRectContainsPoint(_likeCountLabel.bounds, p2_1)){
        _trackingTouch_likeBtn = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
            [_delegate userPortraitDidClick:self];
        }
    }else if (_trackingTouch_likeBtn){
        if ([_delegate respondsToSelector:@selector(changeTweetStausButtonDidClick:)]) {
            [_delegate changeTweetStausButtonDidClick:self];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch_userPortrait || !_trackingTouch_likeBtn) {
        [super touchesCancelled:touches withEvent:event];
    }
}

#pragma mark --- 动画handle
- (void)setLikeStatus:(BOOL)isLike animation:(BOOL)isNeedAnimation{
    UIImage* image = isLike ? [self likeImage] : [self unlikeImage];
    if (isNeedAnimation) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            _likeCountButton.layer.transformScale = 1.7;
        } completion:^(BOOL finished) {
            
            _likeCountButton.image = image;
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _likeCountButton.layer.transformScale = 0.9;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _likeCountButton.layer.transformScale = 1;
                } completion:^(BOOL finished) {
                    _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweetItem.likeCount];
                }];
            }];
        }];
    }else{
        [_likeCountButton setImage:image];
        _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweetItem.likeCount];
    }
}

#pragma mark --- textHandle
- (void)copyText:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:_descTextView.text];
}
#pragma mark --- UITextView delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([_delegate respondsToSelector:@selector(shouldInteractTextView:URL:inRange:)]) {
        [_delegate shouldInteractTextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}
- (void)forwardingEvent:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(textViewTouchPointProcessing:)]) {
        [_delegate textViewTouchPointProcessing:tap];
    }
}

@end
