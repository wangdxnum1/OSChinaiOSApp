//
//  UIImageView+RadiusHandle.m
//  iosapp
//
//  Created by Graphic-one on 16/8/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UIImageView+RadiusHandle.h"

@interface UIImage (RadiusHandle)

- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size;

@end


@implementation UIImage (RadiusHandle)

- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end






@implementation UIImageView (RadiusHandle)
- (void)addCorner:(CGFloat)radius
{
    if (self.image) {
        self.image = [self.image imageAddCornerWithRadius:radius andSize:self.bounds.size];
    }
    return;
}

- (void)handleCornerRadiusWithRadius:(CGFloat)radius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.shouldRasterize = YES;
}

@end
