//
//  ImageCollectionViewCell.h
//  iosapp
//
//  Created by 王恒 on 16/9/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, copy) void(^deleteCell)(ImageCollectionViewCell *cell);
@property (nonatomic, strong) UIImageView *imageView;

-(instancetype)initWithFrame:(CGRect)frame;

@end
