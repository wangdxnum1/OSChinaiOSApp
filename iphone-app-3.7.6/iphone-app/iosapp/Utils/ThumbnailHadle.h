//
//  thumbnailHanle.h
//  iosapp
//
//  Created by Graphic-one on 16/8/17.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface ThumbnailHadle : NSObject

+ (CGSize)thumbnailSizeWithOriginalW:(CGFloat)originalW
                           originalH:(CGFloat)originalH;

@end
