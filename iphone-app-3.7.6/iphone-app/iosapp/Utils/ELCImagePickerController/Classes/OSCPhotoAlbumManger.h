//
//  OSCPhotoAlbumManger.h
//  iosapp
//
//  Created by Graphic-one on 16/7/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

typedef void (^AlbumCompleteHanle)(NSError* error , BOOL isHasAuthorized);

@interface OSCPhotoAlbumManger : NSObject

+ (instancetype) sharePhotoAlbumManger;

- (void) saveImage:(UIImage* )image
         albumName:(NSString* )albumName
    completeHandle:(AlbumCompleteHanle)completeHandle;


@end
