//
//  SoftWareDetailHeaderView.h
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoftWareDetailHeaderView;

@protocol SoftWareDetailHeaderViewDelegate <NSObject>

-(void)softWareDetailHeaderViewClickLeft:(SoftWareDetailHeaderView* )headerView;

-(void)softWareDetailHeaderViewClickRight:(SoftWareDetailHeaderView* )headerView;

@end



@interface SoftWareDetailHeaderView : UIView

@property (nonatomic,weak) id<SoftWareDetailHeaderViewDelegate> delegate;

@end
