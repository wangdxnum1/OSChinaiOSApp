//
//  HomeButtonView.h
//  iosapp
//
//  Created by 李萍 on 16/7/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSCUserItem.h"

@protocol ButtonViewDelegate <NSObject>

@optional
- (void)clickButtonAction:(NSInteger)senderTag;

@end

@interface HomeButtonView : UIView

@property (nonatomic, strong) UIView *redPointView;

@property (nonatomic, strong) OSCUserItem *userInfo;

@property (nonatomic, assign) id <ButtonViewDelegate> delegate;

@end
