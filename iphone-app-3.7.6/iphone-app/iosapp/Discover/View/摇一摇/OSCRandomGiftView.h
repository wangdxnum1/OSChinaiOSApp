//
//  OSCRandomGiftView.h
//  iosapp
//
//  Created by Graphic-one on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCRandomGiftView,OSCRandomGift;
@protocol OSCRandomGiftViewDelegate <NSObject>
@optional
- (void) randomGiftViewDidRandomGiftView:(OSCRandomGiftView* )randomGiftView;

- (void) randomGiftViewDidClickGiftImageView:(OSCRandomGiftView* )randomGiftView;

@end

@interface OSCRandomGiftView : UIView

@property (nonatomic,strong) OSCRandomGift* randomGiftItem;

@property (nonatomic,weak) id<OSCRandomGiftViewDelegate> delegate;

@end
