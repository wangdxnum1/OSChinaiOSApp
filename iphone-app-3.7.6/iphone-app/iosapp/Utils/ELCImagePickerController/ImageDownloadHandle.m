//
//  ImageDownloadHandle.m
//  iosapp
//
//  Created by Graphic-one on 16/8/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ImageDownloadHandle.h"

#import <SDWebImageDownloader.h>
#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import <YYKit.h>

@implementation ImageDownloadHandle

#pragma mark --- retrieve && download image
+ (UIImage *)retrieveMemoryAndDiskCache:(NSString* )imageKey{
/** 检索SDWebImage维护的buffer*/
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageKey];
    if (!image) {
/** 检索YYWebImage维护的buffer*/
        image = [[YYWebImageManager sharedManager].cache getImageForKey:imageKey];
        if (image) {
            return image;
        }else{
            image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageKey];
            if (!image) {
                return nil;
            }else{
                return image;
            }
        }
    }else{
        return image;
    }
}

+ (void)downloadImageWithUrlString:(NSString *)url
                       SaveToDisk:(BOOL)isSaveToDisk
                    completeBlock:(downloaderComplete)completeBlock
{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:url]
                                                        options:SDWebImageDownloaderUseNSURLCache | SDWebImageDownloaderHandleCookies
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (!error) {
            if (image) {
                [[SDImageCache sharedImageCache] storeImage:image forKey:url toDisk:isSaveToDisk];
            }
            if (completeBlock) {
                completeBlock(image , data , error , finished);
            }
        }
    }];
}

@end
