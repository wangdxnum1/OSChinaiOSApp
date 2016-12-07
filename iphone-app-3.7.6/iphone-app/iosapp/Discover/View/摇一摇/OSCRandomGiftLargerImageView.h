//
//  OSCRandomGiftLargerImageView.h
//  iosapp
//
//  Created by Graphic-one on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCRandomGiftLargerImageView , OSCRandomGift;

@protocol OSCRandomGiftLargerImageViewDelegate <NSObject>

-(void)randomGiftLargerImageViewDidClickRightItem:(OSCRandomGiftLargerImageView* )randomGiftLargerImageView;

-(void)randomGiftLargerImageViewDidClickLeftItem:(OSCRandomGiftLargerImageView* )randomGiftLargerImageView;

@end

@interface OSCRandomGiftLargerImageView : UIView

+ (instancetype)randomGiftLargerImageView;

@property (nonatomic,strong) OSCRandomGift* randomGiftItem;

@property (nonatomic,weak) id<OSCRandomGiftLargerImageViewDelegate> delegate;

@property (nonatomic,assign) BOOL leftIsAvailable , rightIsAvailable;

@end
