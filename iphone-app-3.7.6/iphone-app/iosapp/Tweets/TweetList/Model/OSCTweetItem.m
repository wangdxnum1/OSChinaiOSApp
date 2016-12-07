//
//  OSCTweetItem.m
//  iosapp
//
//  Created by Graphic-one on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetItem.h"
#import <UIKit/UIFont.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AsyncDisplayTableViewCell.h"
#import "Utils.h"
#import "ThumbnailHadle.h"
#import "OSCModelHandler.h"

@implementation OSCTweetItem

+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"audio" : [OSCTweetAudio class],
             @"images" : [OSCTweetImages class],
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"audio" : [OSCTweetAudio class],
             @"images" : [OSCTweetImages class],
             };
}


static MultipleImageViewFrame _multipleImageViewFrameZero;
- (MultipleImageViewFrame)multipleImageViewFrameZero{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _multipleImageViewFrameZero.frame = CGRectZero;
        _multipleImageViewFrameZero.line = 0;
        _multipleImageViewFrameZero.row = 0;
    });
    return _multipleImageViewFrameZero;
}

- (void)calculateLayout{
    //text path layuot
    NSAttributedString* string = [Utils contentStringFromRawString:_content];
    CGSize size = [string boundingRectWithSize:(CGSize){(kScreen_W - padding_left - userPortrait_W - userPortrait_SPACE_nameLabel - padding_right),MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin context:nil].size ;
    CGRect descTextFrame = (CGRect){{0,0},{kScreen_W - padding_left - userPortrait_W - userPortrait_SPACE_nameLabel - padding_right,size.height + 3}};
    _descTextFrame = descTextFrame;
    
    //images path layout
    if (_images.count == 0) {//纯文字
        _imageFrame = CGRectZero;
        _multipleFrame = [self multipleImageViewFrameZero];;
        _rowHeight = 0;
    }else if (_images.count == 1){//单图
        OSCTweetImages* onceImage = [_images lastObject];
        _imageFrame = (CGRect){{0,0},[ThumbnailHadle thumbnailSizeWithOriginalW:onceImage.w originalH:onceImage.h]};
        _multipleFrame = [self multipleImageViewFrameZero];
        _rowHeight = 0;
    }else{//多图
        _imageFrame = CGRectZero;
        _rowHeight = 0;
        
        int count = (int)_images.count;
        MultipleImageViewFrame multipleImageViewFrame;
        
#pragma TODO:: 使用宏代替 multiple_WH & imageItem_WH
        /** 全局padding值*/
        CGFloat Multiple_Padding = 69;
        CGFloat ImageItemPadding = 8;
        
        /** 动态值维护*/
        CGFloat multiple_WH = ceil(([UIScreen mainScreen].bounds.size.width - (Multiple_Padding * 2)));
        CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
        
        if (count <= 3) {
            multipleImageViewFrame.line = 1;
            multipleImageViewFrame.row = count;
            multipleImageViewFrame.frame = (CGRect){{0,0},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH}};
        }else if (count <= 6){
            if (count == 4) {
                multipleImageViewFrame.line = 2;
                multipleImageViewFrame.row = 2;
            }else{
                multipleImageViewFrame.line = 2;
                multipleImageViewFrame.row = 3;
            }
            multipleImageViewFrame.frame = (CGRect){{0,0},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH * 2 + ImageItemPadding}};
        }else{
            multipleImageViewFrame.line = 3;
            multipleImageViewFrame.row = 3;
            multipleImageViewFrame.frame = (CGRect){{0,0},{imageItem_WH * 3 + ImageItemPadding * 2,imageItem_WH * 3 + ImageItemPadding * 2}};
        }
        _multipleFrame = multipleImageViewFrame;
    }
    
}
@end


#pragma mark -
#pragma mark --- 动弹作者
@implementation OSCTweetAuthor

@end


#pragma mark -
#pragma mark --- 动弹Code
@implementation OSCTweetCode

@end


#pragma mark -
#pragma mark --- 动弹音频 && 视频
@implementation OSCTweetAudio

@end


#pragma mark -
#pragma mark --- 动弹图片
@implementation OSCTweetImages

@end



#pragma mark - 推荐话题
/** 推荐话题列表使用到Item */
@implementation OSCTweetTopicItem
+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"items" : [OSCTweetItem class],
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"items" : [OSCTweetItem class],
             };
}

@end
