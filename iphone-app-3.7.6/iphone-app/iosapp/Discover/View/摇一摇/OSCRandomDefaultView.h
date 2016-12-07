//
//  OSCRandomDefaultView.h
//  iosapp
//
//  Created by Graphic-one on 16/10/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCRandomDefaultView,OSCRandomMessageItem;

@protocol OSCRandomDefaultViewDelegate <NSObject>

- (void) randomDefaultViewDidClickDefaultView:(OSCRandomDefaultView* )randomDefaultView ;

@end

@interface OSCRandomDefaultView : UIView

@property (nonatomic,strong) OSCRandomMessageItem* randomMessageItem;

@property (nonatomic,weak) id <OSCRandomDefaultViewDelegate> delegate;

@end
