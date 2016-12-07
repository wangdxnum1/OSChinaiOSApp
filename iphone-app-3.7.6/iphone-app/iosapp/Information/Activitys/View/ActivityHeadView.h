//
//  ActivityHeadView.h
//  iosapp
//
//  Created by 李萍 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBanner.h"

@protocol ActivityHeadViewDelegate <NSObject>

- (void)clickScrollViewBanner:(NSInteger)bannerTag;

@end

@interface ActivityHeadView : UIView

@property (nonatomic, strong) NSMutableArray *banners;
@property (nonatomic, strong) id <ActivityHeadViewDelegate> delegate;

@end

@interface BottomImageView : UIView

@property (nonatomic, strong) UIImageView *bottomImage;
@property (nonatomic, strong) UIImageView *subImageView;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *descLable;

- (void)setContentForTopImages:(OSCBanner *)banner;

@end
