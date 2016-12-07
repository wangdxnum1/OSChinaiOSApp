//
//  ImageViewerController.h
//  iosapp
//
//  Created by chenhaoxiang on 11/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewerController : UIViewController

- (instancetype)initWithImageURL:(NSURL *)imageURL;
- (instancetype)initWithImage:(UIImage *)image;

@end
