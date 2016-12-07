//
//  QuartzCanvasView.h
//  animationLayerDisplay
//
//  Created by Graphic-one on 16/7/28.
//  Copyright © 2016年 Graphic-one. All rights reserved.
//

#import <UIKit/UIKit.h>

struct OffestCenter{
    CGFloat offestX;
    CGFloat offestY;
};
typedef struct OffestCenter OffestCenter;

struct GradientColor{
    CGColorRef startColor;
    CGColorRef endColor;
};
typedef struct GradientColor GradientColor;

@interface QuartzCanvasView : UIView

/** QuartzCanvasView的背景色 默认是绿色 (纯色时使用)*/
@property (nonatomic,strong) UIColor* bgColor;///< default is [UIColor greenColor]

/** QuartzCanvasView的渐变背景色 */
@property (nonatomic,assign) GradientColor gradientColor;///< default is {NULL , NULL}

/** 绘制线的颜色 默认是白色 */
@property (nonatomic,strong) UIColor* strokeColor;///< default is [UIColor whiteColor]

/** layer运动的速率 默认为20 */
@property (nonatomic,assign) CGFloat speed;///< default is 2.2

/** 圆集合的中心点偏移值 默认是(0,0)  */
@property (nonatomic,assign) OffestCenter offestCenter;///< the center offest , default (0,0);

/** 最外圆的半径值 默认是所设frame的宽度的一半 (用作下拉放大用)*/
@property (nonatomic,assign) NSInteger biggestRoundRadius;///< default is MAX(QuartzCanvasView.frame.size.width * 0.5 , QuartzCanvasView.frame.size.height * 0.5)

/** 最小圆(最内层圆)的半径值限制 */
@property (nonatomic,assign) NSInteger minimumRoundRadius;///< default is 30px

/** 最外圆的运动时间 其他小圆按比例缩放运动时间*/
@property (nonatomic,assign) CFTimeInterval duration;///< default is 20s

/** 随机性开关 
 开启之后:小圆点的大小 && 绘制的圆的半径会在规律性下浮动变化 
 关闭之后:小圆点的大小 && 绘制的圆的半径单纯呈规律性变化
 */
@property (nonatomic,assign) BOOL openRandomness;///< default is NO

@end
