//
//  BannerScrollView.h
//  iosapp
//
//  Created by 李萍 on 16/7/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBanner.h"

@protocol BannerScrollViewDelegate <NSObject>

- (void)clickedScrollViewBanners:(NSInteger)bannerTag;

@end

#pragma mark - 滚动图

@interface BannerScrollView : UIView

@property (nonatomic, strong) NSMutableArray *banners;
@property (nonatomic, strong) id <BannerScrollViewDelegate> delegate;

@end

#pragma mark - 背景图片加文字
@interface BannerImageView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLable;

- (void)setContentForBanners:(OSCBanner *)banner;

@end