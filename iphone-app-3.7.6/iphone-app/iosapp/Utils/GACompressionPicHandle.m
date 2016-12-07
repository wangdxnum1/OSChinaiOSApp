//
//  GACompressionPicHandle.m
//  iOS压缩算法
//
//  Created by Graphic-one on 16/9/27.
//  Copyright © 2016年 Graphic-one. All rights reserved.
//

#import "GACompressionPicHandle.h"


@implementation GACompressionPicHandle

static GACompressionPicHandle* _shareCompressionPicHandle;
+ (instancetype)shareCompressionPicHandle{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareCompressionPicHandle = [[GACompressionPicHandle alloc]init];
    });
    return _shareCompressionPicHandle;
}

- (NSData* )scaleToSize:(CGSize)size
                   image:(UIImage* )picture
{    
    CGFloat width = CGImageGetWidth(picture.CGImage);
    CGFloat height = CGImageGetHeight(picture.CGImage);
    float verticalRadio = size.height * 1.0 / height;
    float horizontalRadio = size.width * 1.0 / width;
    
    float radio = 1;
    if(verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }else{
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    width = width * radio;
    height = height * radio;
    
    int xPos = (size.width - width) / 2;
    int yPos = (size.height - height) / 2;

    UIGraphicsBeginImageContext(size);

    [picture drawInRect:CGRectMake(xPos, yPos, width, height)];

    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    NSData* scaledImageData = UIImageJPEGRepresentation(scaledImage, 1);

    CGFloat compressionRatio = 0.9f;
    NSData* tagerImageData = scaledImageData;
    NSLog(@"tagerImageData.length : %lu",(unsigned long)tagerImageData.length);
    while (tagerImageData.length > stand_size && compressionRatio > 0) {
        if (compressionRatio < min_compressionRatio) {
            if ([_delegate respondsToSelector:@selector(CompressionPicHandle:CompressionFailureInfo:)]) {
                [_delegate CompressionPicHandle:self CompressionFailureInfo:@"图片过大"];
            }
        }
        @autoreleasepool {
            NSData* newCompressionData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
            tagerImageData = newCompressionData;
        }
        compressionRatio = compressionRatio - 0.12;
        NSLog(@"tagerImageData.length : %lu , compressionRatio : %lf",tagerImageData.length,compressionRatio);
    }
    NSLog(@"compressionRatio : %lf",compressionRatio);
    
    return tagerImageData;
}

- (NSData *)imageByScalingAndCroppingForSize:(CGSize)targetSize
                                        image:(UIImage *)image
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor){
            scaleFactor = widthFactor; // scale to fit height
        }else{
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    UIGraphicsEndImageContext();
    
    NSData* scaledImageData = UIImageJPEGRepresentation(newImage, 1);
    
    CGFloat compressionRatio = 0.9f;
    NSData* tagerImageData = scaledImageData;
    NSLog(@"tagerImageData.length : %lu",(unsigned long)tagerImageData.length);
    while (tagerImageData.length > stand_size && compressionRatio > 0) {
        if (compressionRatio < min_compressionRatio) {
            if ([_delegate respondsToSelector:@selector(CompressionPicHandle:CompressionFailureInfo:)]) {
                [_delegate CompressionPicHandle:self CompressionFailureInfo:@"图片过大"];
            }
        }
        @autoreleasepool {
            NSData* newCompressionData = UIImageJPEGRepresentation(newImage, compressionRatio);
            tagerImageData = newCompressionData;
        }
        compressionRatio = compressionRatio - 0.12;
        NSLog(@"tagerImageData.length : %lu , compressionRatio : %lf",tagerImageData.length,compressionRatio);
    }
    NSLog(@"compressionRatio : %lf",compressionRatio);
    
    return tagerImageData;
}

#pragma mark --- fileSize
+ (CGFloat)fileSize:(NSURL *)path
{
    //    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:path.absoluteString error:nil] fileSize] / 1024 / 1024;
}

@end
