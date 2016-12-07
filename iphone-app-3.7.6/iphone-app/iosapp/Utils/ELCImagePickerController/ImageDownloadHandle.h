//
//  ImageDownloadHandle.h
//  iosapp
//
//  Created by Graphic-one on 16/8/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^downloaderComplete)(UIImage *image, NSData *data, NSError *error, BOOL finished);

@interface ImageDownloadHandle : NSObject

/** 检索内存和磁盘中是否有图片缓存*/
+ (UIImage *) retrieveMemoryAndDiskCache:(NSString* )imageKey;

/** 对图片进行下载 */
+ (void) downloadImageWithUrlString:(NSString* )url
                       SaveToDisk:(BOOL)isSaveToDisk
                      completeBlock:(downloaderComplete)completeBlock;

@end
