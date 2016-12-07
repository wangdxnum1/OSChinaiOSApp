//
//  OSCImageTweetCell.m
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCImageTweetCell.h"
#import "OSCTweetItem.h"
#import "UIImageView+RadiusHandle.h"
#import "UIColor+Util.h"
#import "ImageDownloadHandle.h"
#import "OSCPhotoGroupView.h"
#import "Utils.h"
#import <UIImage+GIF.h>

#import <YYKit.h>

@interface OSCImageTweetCell ()<UITextViewDelegate>{
    __weak UIImageView* _userPortrait;
    __weak YYLabel* _nameLabel;
    __weak UITextView* _descTextView;
    __weak UIImageView* _imageView;
    __weak UIImageView* _imageTypeLogo;
    __weak YYLabel* _timeAndSourceLabel;
    __weak UIImageView* _likeCountButton;
    __weak YYLabel* _likeCountLabel;
    __weak UIImageView* _commentCountBtn;
    __weak YYLabel* _commentCountLabel;
    __weak CALayer* _colorLine;
}
@end

@implementation OSCImageTweetCell{
    CGFloat _rowHeight;
    CGSize _descTextViewSize;
    CGSize _imageSize;
    
    BOOL _trackingTouch_userPortrait;
    BOOL _trackingTouch_imageView;
    BOOL _trackingTouch_likeBtn;
}

+(instancetype)returnReuseImageTweetCellWithTableView:(UITableView *)tableView
                                           identifier:(NSString *)reuseIdentifier
{
    OSCImageTweetCell* imageTweetCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!imageTweetCell) {
        imageTweetCell = [[OSCImageTweetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [imageTweetCell addSubViews];
    }
    return imageTweetCell;
}

- (void)addSubViews{
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
    
    UIImageView* imageView = [UIImageView new];
    _imageView = imageView;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
    _imageView.userInteractionEnabled = NO;
    [self.contentView addSubview:_imageView];
//    图片类型标识
    UIImageView* imageTypeLogo = [UIImageView new];
    _imageTypeLogo = imageTypeLogo;
    imageTypeLogo.hidden = YES;
    [_imageView addSubview:imageTypeLogo];
    
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
    
    [self.contentView addSubview:_likeCountLabel];
    
    UIImageView* likeCountButton = [[UIImageView alloc]initWithImage:[self unlikeImage]];
    _likeCountButton = likeCountButton;
    _likeCountButton.contentMode = UIViewContentModeTopRight;
    [self.contentView addSubview:_likeCountButton];
    
    CALayer* colorLine = [CALayer new];
    _colorLine = colorLine;
    _colorLine.backgroundColor = [UIColor separatorColor].CGColor;
    [self.contentView.layer addSublayer:_colorLine];
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
    
    _imageView.left = _descTextView.left;
    _imageView.top = CGRectGetMaxY(_descTextView.frame) + descTextView_space_imageView;
    _imageView.size = _imageSize;
    
    _imageTypeLogo.frame = (CGRect){{_imageView.bounds.size.width - 18 - 2,_imageView.bounds.size.height - 11 - 2 },{18,11}};
    
    _timeAndSourceLabel.left = _descTextView.left;
    _timeAndSourceLabel.top = CGRectGetMaxY(_imageView.frame) + imageView_space_timeAndSourceLabel;
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

-(void)setTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;
    
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
    
    OSCTweetImages* imageData = [tweetItem.images lastObject];
    BOOL isGif = [imageData.thumb hasSuffix:@".gif"];
    if (isGif) {
        _imageTypeLogo.image = [self gifImage];
        _imageTypeLogo.hidden = NO;
    }
    
    UIImage* largerImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.href];
    
    if (largerImage) {
        if (isGif) {
            NSData *dataImage = UIImagePNGRepresentation(largerImage);
            largerImage = [UIImage sd_animatedGIFWithData:dataImage];
        }
        [_imageView setImage:largerImage];
        _imageView.userInteractionEnabled = YES;
    }else{
        UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.thumb];
        if (!image) {
            _imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
            _imageView.userInteractionEnabled = NO;
            [ImageDownloadHandle downloadImageWithUrlString:imageData.thumb SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isGif) {
                        NSData *dataImage = UIImagePNGRepresentation(image);
                        UIImage* gifImage = [UIImage sd_animatedGIFWithData:dataImage];
                        [_imageView setImage:gifImage];
                    }else{
                        [_imageView setImage:image];
                    }
                    _imageView.userInteractionEnabled = YES;
                });
            }];
        }else{
            if (isGif) {
                NSData *dataImage = UIImagePNGRepresentation(image);
                image = [UIImage sd_animatedGIFWithData:dataImage];
            }
            [_imageView setImage:image];
            _imageView.userInteractionEnabled = YES;
        }
    }
    
    if (tweetItem.liked) {
        [_likeCountButton setImage:[self likeImage]];
    } else {
        [_likeCountButton setImage:[self unlikeImage]];
    }
    
    _likeCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetItem.likeCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetItem.commentCount];
    
    _rowHeight = tweetItem.rowHeight;
    _descTextViewSize = tweetItem.descTextFrame.size;
    _imageSize = tweetItem.imageFrame.size;
    self.contentView.height = _rowHeight;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    _userPortrait.image = nil;
    _imageView.image = nil;
    _imageTypeLogo.image = nil;
    _imageTypeLogo.hidden = YES;
    _rowHeight = 0 ;
    _descTextViewSize = CGSizeZero;
    _imageSize = CGSizeZero;
}

#pragma mark --- 触摸分发
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _trackingTouch_userPortrait = NO;
    _trackingTouch_likeBtn = NO;
    _trackingTouch_imageView = NO;
    UITouch *t = touches.anyObject;
    CGPoint p1 = [t locationInView:_userPortrait];
    CGPoint p2 = [t locationInView:_likeCountButton];
    CGPoint p2_1 = [t locationInView:_likeCountLabel];
    CGPoint p3 = [t locationInView:_imageView];
    if (CGRectContainsPoint(_userPortrait.bounds, p1)) {
        _trackingTouch_userPortrait = YES;
    }else if(CGRectContainsPoint(_likeCountButton.bounds, p2) || CGRectContainsPoint(_likeCountLabel.bounds, p2_1)){
        _trackingTouch_likeBtn = YES;
    }else if(CGRectContainsPoint(_imageView.bounds, p3)){
        _trackingTouch_imageView = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_trackingTouch_userPortrait) {
        if ([_delegate respondsToSelector:@selector(userPortraitDidClick:)]) {
            [_delegate userPortraitDidClick:self];
        }
    }else if(_trackingTouch_likeBtn){
        if ([_delegate respondsToSelector:@selector(changeTweetStausButtonDidClick:)]) {
            [_delegate changeTweetStausButtonDidClick:self];
        }
    }else if (_trackingTouch_imageView){
        UIImageView* fromView = _imageView;
        OSCTweetImages* tweetItem = [self.tweetItem.images lastObject];
        
        OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
        currentPhotoItem.largeImageURL = [NSURL URLWithString:tweetItem.href];
        currentPhotoItem.thumbView = fromView;
        currentPhotoItem.largeImageSize = (CGSize){tweetItem.w,tweetItem.h};
        
        OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
        
        if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
            [_delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch_userPortrait || !_trackingTouch_likeBtn || !_trackingTouch_imageView) {
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
