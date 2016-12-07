//
//  QuartzCanvasView.m
//  animationLayerDisplay
//
//  Created by Graphic-one on 16/7/28.
//  Copyright © 2016年 Graphic-one. All rights reserved.
//

#import "QuartzCanvasView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#import "Utils.h"
#import "UIDevice+SystemInfo.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define PI 3.14159265358979323846

@interface QuartzCanvasView (){
    CAGradientLayer* _gradientLayer;
    
    NSMutableArray* _layers;
    NSMutableArray* _keyFrameAnis;
}

@end

@implementation QuartzCanvasView{
    CGPoint _center;
}

#pragma mark --- Initialize
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _gradientLayer = [CAGradientLayer new];
        
        self.strokeColor = [UIColor whiteColor];
        self.bgColor = [UIColor greenColor];
        self.speed = 2.2;
        self.duration = 16;
        self.offestCenter = (OffestCenter){0,0};
        _openRandomness = NO;
        
        CGFloat centerX = frame.size.width * 0.5;
        CGFloat centerY = frame.size.height * 0.5;
        _center = (CGPoint){centerX,centerY};
        self.biggestRoundRadius = centerX + 16;
        self.minimumRoundRadius = 15;
        _layers = [NSMutableArray arrayWithCapacity:5];
        _keyFrameAnis = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

#pragma mark --- set Method 
-(void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    self.backgroundColor = _bgColor;
}
-(void)setStrokeColor:(UIColor *)strokeColor{
    if (_strokeColor != strokeColor) {
        _strokeColor = strokeColor;
        [self setNeedsDisplay];
    }
}
-(void)setGradientColor:(GradientColor)gradientColor{
    if (gradientColor.startColor != _gradientColor.startColor || gradientColor.endColor != _gradientColor.endColor) {
        _gradientColor = gradientColor;
        [self setNeedsDisplay];
    }
}
-(void)setOffestCenter:(OffestCenter)offestCenter{
    if (_offestCenter.offestX != offestCenter.offestX ||  _offestCenter.offestY != offestCenter.offestY) {
        _offestCenter = offestCenter;
        
        CGFloat originX = _center.x + _offestCenter.offestX;
        CGFloat originY = _center.y + _offestCenter.offestY;
        _center = (CGPoint){originX,originY};
        
        [self setNeedsDisplay];
    }
}
-(void)setBiggestRoundRadius:(NSInteger)biggestRoundRadius{
    if (_biggestRoundRadius != biggestRoundRadius) {
        _biggestRoundRadius = biggestRoundRadius;
        [self setNeedsDisplay];
    }
}
-(void)setSpeed:(CGFloat)speed{
    if (_speed != speed) {
        _speed = speed;
        [self setNeedsDisplay];
    }
}

#pragma mark --- drawRect (display)
- (void)drawRect:(CGRect)rect {
    NSInteger i = 0;
    CGFloat changeRadius = self.minimumRoundRadius;
    CGFloat standardRadius = MAX(self.bounds.size.width * 0.5, self.bounds.size.height - _center.y);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self makeGradientColor:ctx];
    
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);//画笔线的颜色
    CGContextSetLineWidth(ctx, 1.0);//线的宽度
    
/** 从最内层圆开始绘制 */
    while (changeRadius < standardRadius) {
        CGContextAddArc(ctx, _center.x, _center.y, changeRadius, 0, 2*PI, 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        CALayer* layer = [[CALayer alloc]init];
        layer.backgroundColor = self.strokeColor.CGColor;
        int layerSize = (arc4random() % 4) + 8;
//        NSLog(@"%lu",(unsigned long)layerSize);
        layer.frame = (CGRect){{0,0},{layerSize,layerSize}};
        layer.cornerRadius = 5;
        [self.layer addSublayer:layer];
        [_layers addObject:layer];
        
        CAKeyframeAnimation* keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        keyFrameAnimation.repeatCount = MAXFLOAT;
        keyFrameAnimation.repeatDuration = MAXFLOAT;
//        keyFrameAnimation.autoreverses = YES;//翻转动画
        keyFrameAnimation.speed = self.speed - i * 0.21;
        if (i % 2 != 0) { keyFrameAnimation.speed = - keyFrameAnimation.speed;}
        keyFrameAnimation.calculationMode = kCAAnimationPaced;
        keyFrameAnimation.rotationMode = kCAAnimationRotateAuto;
        
/** UIBezierPath 创建路径 */
//        UIBezierPath * circlePath = [UIBezierPath bezierPathWithArcCenter:_center
//                                                                   radius:changeRadius
//                                                               startAngle:-180
//                                                                 endAngle:180
//                                                                clockwise:YES];
//        keyFrameAnimation.path = circlePath.CGPath;
        
        
        /** core Graphics 创建路径 */
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddEllipseInRect(path, NULL, CGRectMake(_center.x - changeRadius, _center.y - changeRadius, changeRadius * 2, changeRadius * 2));
        keyFrameAnimation.path = path;
        CGPathRelease(path);
        
        
/** CFAutorelease添加圆形路径 */
//        keyFrameAnimation.path = CFAutorelease(CGPathCreateWithEllipseInRect(CGRectMake(_center.x - changeRadius, _center.y - changeRadius, changeRadius * 2, changeRadius * 2), NULL));

//        NSLog(@"%@",keyFrameAnimation.values);
        
        keyFrameAnimation.duration = _duration - i * 4;
        [layer addAnimation:keyFrameAnimation forKey:@"PostionKeyframeValueAni"];
        [_keyFrameAnis addObject:keyFrameAnimation];
        
        i++;
        changeRadius = changeRadius + 40 + i * 2;;
    }
    
/** 防御性绘制 */
    CGFloat lastChangeRadius = changeRadius - 40 - i * 2;
    if (standardRadius - lastChangeRadius > 40) {
        CGContextAddArc(ctx, _center.x, _center.y, standardRadius + 3, 0, 2*PI, 0);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    
/** 从最外层的圆开始绘制 
    //机型判断
    DeviceResolution resolution = [UIDevice currentDeviceResolution];
    if (resolution == Device_iPhone_4 || resolution == Device_iPhone_4s) {
        NSLog(@"4 && 4s");
        changeRadius = _openRandomness ? (biggestRadius - (40 + i*3)) : biggestRadius - 40;
    }else if (resolution == Device_iPhone_5 || resolution == Device_iPhone_5c || resolution == Device_iPhone_5s || resolution == Device_iPhone_se){
        NSLog(@"5 && 5c && 5s");
        changeRadius = _openRandomness ? (biggestRadius - (50 + i*3)) : biggestRadius - 50;
    }else if (resolution == Device_iPhone_6 || resolution == Device_iPhone_6s){
        NSLog(@"6 && 6s");
        changeRadius = _openRandomness ? (biggestRadius - (60 + i*3)) : biggestRadius - 60;
    }else if (resolution == Device_iPhone_6p || resolution == Device_iPhone_6sp){
        NSLog(@"6p && 6sp");
        changeRadius = _openRandomness ? (biggestRadius - (70 + i*3)) : biggestRadius - 70;
    }
    
    
    while (changeRadius > 0) {
        CGContextAddArc(ctx, _center.x, _center.y, changeRadius, 0, 2*PI, 0);
        CGContextDrawPath(ctx, kCGPathStroke);
        CALayer* layer = [[CALayer alloc]init];
        layer.backgroundColor = self.strokeColor.CGColor;
        int layerSize = (arc4random() % 4) + 8;
        NSLog(@"%lu",(unsigned long)layerSize);
        layer.frame = (CGRect){{0,0},{layerSize,layerSize}};
        layer.cornerRadius = 5;
        [self.layer addSublayer:layer];
        [_layers addObject:layer];
        
        CAKeyframeAnimation* keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        keyFrameAnimation.repeatCount = MAXFLOAT;
        keyFrameAnimation.repeatDuration = MAXFLOAT;
//        keyFrameAnimation.autoreverses = YES;//翻转动画
        keyFrameAnimation.speed = self.speed - i * 0.21;
        if (i == 1) { keyFrameAnimation.speed = - keyFrameAnimation.speed;}
        keyFrameAnimation.calculationMode = kCAAnimationPaced;
        keyFrameAnimation.rotationMode = kCAAnimationRotateAuto;
//
    //UIBezierPath 创建路径
//        UIBezierPath * circlePath = [UIBezierPath bezierPathWithArcCenter:_center
//                                                                   radius:changeRadius
//                                                               startAngle:-180
//                                                                 endAngle:180
//                                                                clockwise:YES];
//        keyFrameAnimation.path = circlePath.CGPath;

 
    //core Graphics 创建路径
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathAddEllipseInRect(path, NULL, CGRectMake(_center.x - changeRadius, _center.y - changeRadius, changeRadius * 2, changeRadius * 2));
//        keyFrameAnimation.path = path;
//        CGPathRelease(path);

    
    //CFAutorelease添加圆形路径
//        keyFrameAnimation.path = CFAutorelease(CGPathCreateWithEllipseInRect(CGRectMake(_center.x - changeRadius, _center.y - changeRadius, changeRadius * 2, changeRadius * 2), NULL));
//
//        NSLog(@"%@",keyFrameAnimation.values);
//
//        keyFrameAnimation.duration = _duration - i * 4;
//        [layer addAnimation:keyFrameAnimation forKey:@"PostionKeyframeValueAni"];
//        [_keyFrameAnis addObject:keyFrameAnimation];
//        
        i++;
        changeRadius = (changeRadius - (50 - i*3));;
        if (changeRadius < self.minimumRoundRadius) { break; }
    }
*/
}

#pragma mrak --- 球形渐变
- (void) makeGradientColor:(CGContextRef)ctx{
    UIGraphicsPushContext(ctx);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGColorRef startColor = _gradientColor.startColor;
    CGColorRef endColor = _gradientColor.endColor;
    UIColor *colors[2] = {[UIColor colorWithHex:0x24CF5F], [UIColor colorWithHex:0x20B955]};
    CGFloat components[2*4];
    
    if (startColor == NULL && endColor == NULL) {
        for (int i = 0; i < 2; i++) {
            const CGFloat *tmpcomponents = CGColorGetComponents(_bgColor.CGColor);//color(r,g,b,alpha)
            for (int j = 0; j < 4; j++) {
                components[i * 4 + j] = tmpcomponents[j];
            }
        }
    } else {
        for (int i = 0; i < 2 ; i++) {
            CGColorRef tmpcolorRef = colors[i].CGColor;
            const CGFloat *tmpcomponents = CGColorGetComponents(tmpcolorRef);//color(r,g,b,alpha)
            for (int j = 0; j < 4; j++) {
                components[i * 4 + j] = tmpcomponents[j];
            }
        }
    }

    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL,2);
    CGColorSpaceRelease(colorSpace),colorSpace = NULL;
    
//    勾股定理得出渐变绘制的半径 sqrt()开二次方  pow()算二次方
    NSInteger drawRadius = sqrt(pow(self.bounds.size.width, 2) + pow(self.bounds.size.height, 2));
    
    CGContextDrawRadialGradient(ctx, gradient, _center, 0.f, _center, drawRadius, 0);
    
    CGGradientRelease(gradient),gradient = NULL;
    UIGraphicsPopContext();
}

@end
