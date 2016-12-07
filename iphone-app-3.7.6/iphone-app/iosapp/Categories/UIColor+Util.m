//
//  UIColor+Util.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "UIColor+Util.h"
#import "AppDelegate.h"

@implementation UIColor (Util)

#pragma mark - Hex

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHex:(int)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}


#pragma mark - theme colors

/* 列表整体背景色 */
+ (UIColor *)themeColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x2c2c2c];
    }
    return [UIColor colorWithHex:0xebebf3];
}

/* 用户名颜色 */
+ (UIColor *)nameColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x25933a];
    }
    return [UIColor colorWithHex:0x087221];//0x24CF5F
}

+ (UIColor *)titleColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0xcdcdcd];
    }
    return [UIColor blackColor];
}

+ (UIColor *)separatorColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x3c3c3c];
    }
    return [UIColor colorWithHex:0xC8C7CC];//0xd9d9df];
}

+ (UIColor *)cellsColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x2c2c2c];
    }
    return [UIColor whiteColor];
}

+ (UIColor *)titleBarColor//标题滚动按钮背景色
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return  [UIColor colorWithHex:0x333333];
    }
    return [UIColor colorWithHex:0xf6f6f6];
}

/* 动弹列表内容字体颜色 */
+ (UIColor *)contentTextColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return  [UIColor colorWithHex:0xcdcdcd];
    }
    return [UIColor colorWithHex:0x272727];
}


+ (UIColor *)selectTitleBarColor
{
    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return  [UIColor colorWithHex:0x114818];//[UIColor colorWithRed:0.067 green:0.282 blue:0.094 alpha:1.0];
    }
    return [UIColor colorWithHex:0xE1E1E1];
}

/* 导航栏背景色 */
+ (UIColor *)navigationbarColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x114818];//0x13822E];//
    }
    return [UIColor colorWithHex:0x24cf5f];//colorWithHex:0x15A230
}

+ (UIColor *)selectCellSColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x171717];
    }
//    return [UIColor colorWithHex:0xcbcbcb];
    return [UIColor colorWithHex:0xfcfcfc];
}

+ (UIColor *)labelTextColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x4a4a4a];
    }
    return [UIColor whiteColor];
}

+ (UIColor *)teamButtonColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x333333];
    }
    return [UIColor colorWithHex:0xfbfbfd];
}

+ (UIColor *)infosBackViewColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x181818 alpha:0.6];
    }
    return [UIColor clearColor];
}

+ (UIColor *)lineColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x129069 alpha:0.6];
    }
    return [UIColor colorWithHex:0x2bc157];
}

+ (UIColor *)borderColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x129069 alpha:0.6];
    }
    return [UIColor lightGrayColor];
}

+ (UIColor *)refreshControlColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x13502A];
    }
    return [UIColor colorWithHex:0x21B04B];
}

/*
 新版 日夜间颜色
 */
/* 新 cell.contentView 背景色*/
+ (UIColor *)newCellColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x2c2c2c];
    }
    return [UIColor colorWithHex:0xffffff];
}

/* 新“综合”页面cell.titleLable 标题字体颜色*/
+ (UIColor *)newTitleColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0xcdcdcd];
    }
    return [UIColor colorWithHex:0x111111];
}

///* 新section 问答 按钮选中颜色*/
+ (UIColor *)newSectionButtonSelectedColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x25933a];
    }
    return [UIColor colorWithHex:0x24CF5F];
}

/* 新 分割线*/
+ (UIColor *)newSeparatorColor
{
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x129069 alpha:0.6];
    }
    return [UIColor colorWithHex:0xC8C7CC];
}

/* 次要文字颜色 */
+ (UIColor *)newSecondTextColor
{
    return [UIColor colorWithHex:0x6A6A6A];
}

/* 辅助文字颜色 */
+ (UIColor *)newAssistTextColor
{
    return [UIColor colorWithHex:0x9D9D9D];
}



@end
