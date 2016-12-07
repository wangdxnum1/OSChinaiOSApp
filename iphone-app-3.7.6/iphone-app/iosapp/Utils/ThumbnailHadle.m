//
//  thumbnailHanle.m
//  iosapp
//
//  Created by Graphic-one on 16/8/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ThumbnailHadle.h"
#define SCREEN_W [UIScreen mainScreen].bounds.size.width

@implementation ThumbnailHadle

+ (CGSize)thumbnailSizeWithOriginalW:(CGFloat)originalW
                           originalH:(CGFloat)originalH
{
    /** 全局padding值*/
    CGFloat Multiple_Padding = 69;
    CGFloat ImageItemPadding = 8;
    
    /** 动态值维护*/
    CGFloat multiple_WH = ceil(([UIScreen mainScreen].bounds.size.width - (Multiple_Padding * 2)));
    CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
    
    CGFloat scale = originalW / originalH;
    
    CGFloat standard_W = imageItem_WH + ImageItemPadding;
    CGFloat standard_H = imageItem_WH + ImageItemPadding * 2;
    CGFloat max_W = multiple_WH;
    CGFloat max_H = imageItem_WH * 2 + ImageItemPadding;
    CGFloat result_W = 0;
    CGFloat result_H = 0;

    if (originalW > originalH) {
        result_H = standard_H;
        result_W = MIN(scale * result_H, max_W);
    }else{//originalH > originalW
        result_W = standard_W;
        result_H = MIN(result_W / scale, max_H);
    }
    return (CGSize){result_W,result_H};
}

@end
