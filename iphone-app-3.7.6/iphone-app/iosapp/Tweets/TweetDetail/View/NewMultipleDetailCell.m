//
//  NewMultipleDetailCell.m
//  iosapp
//
//  Created by Graphic-one on 16/7/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewMultipleDetailCell.h"
#import "OSCTweetItem.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "UIView+Util.h"
#import "NSDate+Util.h"
#import "UIImageView+RadiusHandle.h"
#import "OSCPhotoGroupView.h"
#import "ImageDownloadHandle.h"

#import <SDWebImage/SDImageCache.h>
#import <SDWebImageDownloaderOperation.h>
#import <UIImage+GIF.h>
#import <Masonry.h>

@interface NewMultipleDetailCell ()<UITextViewDelegate>{
    NSMutableArray* _imageViewsArray;   //二维数组 _imageViewsArray[line][row]
    
    NSMutableArray<NSString* >* _largerImageUrls;   //本地维护的大图数组
    NSMutableArray<UIImageView* >* _visibleImageViews;   //可见的imageView数组
    
    OSCPhotoGroupView* _photoGroup;
    
    CGFloat _multiple_WH;
    CGFloat _imageItem_WH;
    CGFloat Multiple_Padding;
    CGFloat ImageItemPadding;
}

@end

@implementation NewMultipleDetailCell
{
    __weak UIImageView* _userPortrait;
    __weak UILabel* _nameLabel;
    __weak UITextView* _descTextView;
    
    __weak UIView* _imagesView; //container view
    
    __weak UILabel* _timeLabel;
    __weak UIImageView* _commentImage;
    __weak UIImageView* _likeImage;
}

#pragma mark -
#pragma mark --- init Method
+ (instancetype) multipleDetailCellWith:(OSCTweetItem *)item
                        reuseIdentifier:(NSString *)reuseIdentifier
{
    return [[self alloc] initWithTweetItem:item reuseIdentifier:reuseIdentifier];
}
- (instancetype) initWithTweetItem:(OSCTweetItem *)item
                   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSubViews];
        [self setLayout];
        _item = item;
    }
    return self;
}
- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _largerImageUrls = [NSMutableArray arrayWithCapacity:9];
        _visibleImageViews = [NSMutableArray arrayWithCapacity:9];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setSubViews];
        [self setLayout];
    }
    return self;
}

#pragma mark - 
#pragma mark --- setting SubViews && Layout
-(void)setSubViews{
    UIImageView* userPortrait = [[UIImageView alloc]init];
    userPortrait.userInteractionEnabled = YES;
    userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userPortraitDidClickMethod:)]];
//    [userPortrait setCornerRadius:22];
    _userPortrait = userPortrait;
    [self.contentView addSubview:_userPortrait];
    
    UILabel* nameLabel = [[UILabel alloc]init];
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    nameLabel.numberOfLines = 1;
    nameLabel.textColor = [UIColor newTitleColor];
    _nameLabel = nameLabel;
    [self.contentView addSubview:_nameLabel];
    
    UITextView* descTextView = [[UITextView alloc]init];
    descTextView.userInteractionEnabled = YES;
    descTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    descTextView.backgroundColor = [UIColor clearColor];
    descTextView.font = [UIFont systemFontOfSize:14];
    descTextView.textColor = [UIColor newTitleColor];
    descTextView.editable = NO;
    descTextView.scrollEnabled = NO;
    [descTextView setTextContainerInset:UIEdgeInsetsZero];
    descTextView.textContainer.lineFragmentPadding = 0;
    descTextView.delegate = self;
    _descTextView = descTextView;
    [self.contentView addSubview:_descTextView];
    
    UIView* imagesView = [[UIView alloc]init];
    _imagesView = imagesView;
    [self.contentView addSubview:_imagesView];
    
    UILabel* timeLabel = [[UILabel alloc]init];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor newAssistTextColor];
    _timeLabel = timeLabel;
    [self.contentView addSubview:_timeLabel];
    
    UIImageView* likeImage = [[UIImageView alloc] init];
    likeImage.userInteractionEnabled = YES;
    likeImage.contentMode = UIViewContentModeRight;
    likeImage.image = [UIImage imageNamed:@"ic_thumbup_normal"];
    [likeImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeBtnDidClickMethod:)]];
    _likeImage = likeImage;
    [self.contentView addSubview:_likeImage];
    
    UIImageView* commentImage = [[UIImageView alloc]init];
    commentImage.userInteractionEnabled = YES;
    commentImage.image = [UIImage imageNamed:@"ic_comment_30"];
    [commentImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentBtnDidClickMethod:)]];
    _commentImage = commentImage;
    [self.contentView addSubview:_commentImage];
    
    /** 全局padding值*/
    Multiple_Padding = 16;
    ImageItemPadding = 8;
    
    /** 动态值维护*/
    CGFloat multiple_WH = ceil(([UIScreen mainScreen].bounds.size.width - (Multiple_Padding * 2)));
    _multiple_WH = multiple_WH;
    CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
    _imageItem_WH = imageItem_WH;
    
    [self addMultiples];
}
-(void)setLayout{
    [_userPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.contentView).with.offset(16);
        make.width.and.height.equalTo(@45);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userPortrait.mas_centerY);
        make.left.equalTo(_userPortrait.mas_right).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_descTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_userPortrait.mas_bottom).with.offset(8);
        make.right.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(Multiple_Padding);
        make.top.equalTo(_descTextView.mas_bottom).with.offset(8);
        make.width.equalTo(@(_multiple_WH));
        make.height.equalTo(@(_multiple_WH));
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(16);
        make.top.equalTo(_imagesView.mas_bottom).with.offset(8);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];
    
    [_commentImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@15);
        make.right.equalTo(self.contentView).with.offset(-16);
        make.bottom.equalTo(self.contentView).with.offset(-16);
    }];

    [_likeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@15);
        make.bottom.equalTo(self.contentView).with.offset(-16);
        make.right.equalTo(_commentImage.mas_left).with.offset(-16);
    }];
}

#pragma mark -
#pragma mark --- setting Model
-(void)setItem:(OSCTweetItem *)item{
    _item = item;
    
    [_largerImageUrls removeAllObjects];
    for (OSCTweetImages* imageDataSource in item.images) {
        [_largerImageUrls addObject:imageDataSource.href];
    }
    
    [self settingContentForSubViews:item];
}
#pragma mrak --- 设置内容给子视图
-(void)settingContentForSubViews:(OSCTweetItem* )model{
    UIImage* portrait = [ImageDownloadHandle retrieveMemoryAndDiskCache:model.author.portrait];
    if (!portrait) {
        _userPortrait.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loading"]];
        [ImageDownloadHandle downloadImageWithUrlString:model.author.portrait SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _userPortrait.userInteractionEnabled = YES;
                [_userPortrait setImage:image];
                [_userPortrait addCorner:22];
                if ([_delegate respondsToSelector:@selector(assemblyMultipleTweetCellDidFinsh:)]) {
                    [_delegate assemblyMultipleTweetCellDidFinsh:self];
                }
            });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_userPortrait setImage:portrait];
            [_userPortrait addCorner:22];
        });
    }
    
    _nameLabel.text = model.author.name;

    _descTextView.attributedText = [Utils contentStringFromRawString:model.content];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [[NSDate dateFromString:model.pubDate] timeAgoSinceNow]]];
    [att appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [att appendAttributedString:[Utils getAppclientName:(int)model.appClient]];
    _timeLabel.attributedText = att;
    
    if (model.liked) {
        [_likeImage setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
    } else {
        [_likeImage setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
    }
    
    //    Assignment and update the layout
    [self assemblyContentToImageViewsWithImagesCount:model.images.count];
}


#pragma mark -
#pragma mark --- Using a for loop
-(void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    for (int i = 0 ; i < 3; i++) {//line
        originY = i * (_imageItem_WH + ImageItemPadding);
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            originX = j * (_imageItem_WH + ImageItemPadding);
            UIImageView* imageView = [[UIImageView alloc]init];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImageWithTapGes:)]];
            imageView.backgroundColor = [UIColor newCellColor];
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
            imageView.frame = (CGRect){{originX,originY},{_imageItem_WH,_imageItem_WH}};
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imagesView addSubview:imageView];
//            imageTypeLogo
#pragma TODO
            UIImageView* imageTypeLogo = [UIImageView new];
            imageTypeLogo.frame = (CGRect){{imageView.bounds.size.width - 18 - 2,imageView.bounds.size.height - 11 - 2 },{18,11}};
            imageTypeLogo.userInteractionEnabled = NO;
            imageTypeLogo.hidden = YES;
            [imageView addSubview:imageTypeLogo];
            
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
}
//assembly NewMultipleTweetCell
-(void)assemblyContentToImageViewsWithImagesCount:(NSInteger)count{
    if (count <= 3) {   //Single line layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_imageItem_WH));
        }];
        [self loopAssemblyContentWithLine:1 row:(int)count count:(int)count];
    }else if (count <= 6){  //Double row layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((_imageItem_WH * 2) + ImageItemPadding));
        }];
        if (count == 4) {
            [self loopAssemblyContentWithLine:2 row:2 count:(int)count];
        }else{
            [self loopAssemblyContentWithLine:2 row:3 count:(int)count];
        }
    }else{  //Three lines layout
        [_imagesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_multiple_WH));
        }];
        [self loopAssemblyContentWithLine:3 row:3 count:(int)count];
    }
}
-(void)loopAssemblyContentWithLine:(int)line row:(int)row count:(int)count{
    int dataIndex = 0;
    for (int i = 0; i < line; i++) {
        for (int j = 0; j < row; j++) {
            if (dataIndex == count) return;
            OSCTweetImages* imageData = _item.images[dataIndex];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.tag = dataIndex;
            imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
            imageView.hidden = NO;
            [_visibleImageViews addObject:imageView];
            
            UIImage* largerImage = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.href];
            
            if (!largerImage) {
                UIImage* image = [ImageDownloadHandle retrieveMemoryAndDiskCache:imageData.thumb];
                if (!image) {
                    [ImageDownloadHandle downloadImageWithUrlString:imageData.thumb SaveToDisk:NO completeBlock:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.userInteractionEnabled = YES;
                            if ([imageData.thumb hasSuffix:@".gif"]) {
                                UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                                imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                                imageTypeLogo.hidden = NO;
                                NSData *dataImage = UIImagePNGRepresentation(image);
                                UIImage* gifImage = [UIImage sd_animatedGIFWithData:dataImage];
                                [imageView setImage:gifImage];
                            }else{
                                [imageView setImage:image];
                            }
                        });
                    }];
                }else{
                    imageView.userInteractionEnabled = YES;
                    if ([imageData.thumb hasSuffix:@".gif"]) {
                        UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                        imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                        imageTypeLogo.hidden = NO;
                        NSData *dataImage = UIImagePNGRepresentation(image);
                        image = [UIImage sd_animatedGIFWithData:dataImage];
                    }
                    [imageView setImage:image];
                }
            }else{
                imageView.userInteractionEnabled = YES;
                if ([imageData.thumb hasSuffix:@".gif"]) {
                    UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                    imageTypeLogo.image = [UIImage imageNamed:@"gif"];
                    imageTypeLogo.hidden = NO;
                    NSData *dataImage = UIImagePNGRepresentation(largerImage);
                    largerImage = [UIImage sd_animatedGIFWithData:dataImage];
                }
                [imageView setImage:largerImage];
            }
            
            dataIndex++;
            
        }
    }
}

#pragma mark --- click Method
-(void)userPortraitDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(userPortraitDidClick: tapGestures:)]) {
        [_delegate userPortraitDidClick:self tapGestures:tap];
    }
}
-(void)commentBtnDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(commentButtonDidClick:tapGestures:)]) {
        [_delegate commentButtonDidClick:self tapGestures:tap];
    }
}
-(void) likeBtnDidClickMethod:(UITapGestureRecognizer* )tap{
    if ([_delegate respondsToSelector:@selector(likeButtonDidClick:tapGestures:)]) {
        [_delegate likeButtonDidClick:self tapGestures:tap];
    }
}

#pragma mark --- 加载大图
-(void)loadLargeImageWithTapGes:(UITapGestureRecognizer* )tap{
    UIImageView* fromView = (UIImageView* )tap.view;
    int index = (int)fromView.tag;
//        current touch object
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.thumbView = fromView;
    currentPhotoItem.largeImageURL = [NSURL URLWithString:_largerImageUrls[index]];
    
//        all imageItem objects
    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_largerImageUrls.count];
    
    for (int i = 0; i < _largerImageUrls.count; i++) {
        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
        photoItem.thumbView = _visibleImageViews[i];
        photoItem.largeImageURL = [NSURL URLWithString:_largerImageUrls[i]];
        [photoGroupItems addObject:photoItem];
    }
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];

    if ([_delegate respondsToSelector:@selector(loadLargeImageDidFinsh:photoGroupView:fromView:)]) {
        [_delegate loadLargeImageDidFinsh:self photoGroupView:photoGroup fromView:fromView];
    }
}
#pragma mark --- UITextView delegate 
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([_delegate respondsToSelector:@selector(shouldInteractTextView:URL:inRange:)]) {
        [_delegate shouldInteractTextView:textView URL:URL inRange:characterRange];
    }
    return NO;
}

@end
