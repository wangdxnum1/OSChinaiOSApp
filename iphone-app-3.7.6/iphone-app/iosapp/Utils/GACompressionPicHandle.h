//
//  GACompressionPicHandle.h
//  iOS压缩算法
//
//  Created by Graphic-one on 16/9/27.
//  Copyright © 2016年 Graphic-one. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class GACompressionPicHandle;
@protocol GACompressionPicHandleDelegate <NSObject>

- (void)CompressionPicHandle:(GACompressionPicHandle* )handle
      CompressionFailureInfo:(NSString* )info;

@end

#define CompressionMax_W 1224
#define CompressionMax_Size 300 * 1024
/** OSChina 后台限制上传图片的大小*/
#define stand_size 1024 * 800
#define min_compressionRatio 0.3

@interface GACompressionPicHandle : NSObject

+ (instancetype)shareCompressionPicHandle;

@property (nonatomic,weak) id<GACompressionPicHandleDelegate> delegate;

/** 分辨率越小反而越占用时间 建议分辨率高的图片使用*/
- (NSData* )scaleToSize:(CGSize)size
                   image:(UIImage* )picture;

/** 受到宽高比例问题 越接近正方形所用的时间越小 */
- (NSData *)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                        image:(UIImage *)image;

@end
