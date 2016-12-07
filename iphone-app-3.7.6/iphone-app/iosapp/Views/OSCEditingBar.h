//
//  OSCEditingBar.h
//  iosapp
//
//  Created by 李萍 on 16/9/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowingTextView.h"

@interface OSCEditingBar : UIToolbar

@property (nonatomic, copy) void (^sendContent)(NSString *content);

@property (nonatomic, strong) GrowingTextView *editView;
@property (nonatomic, strong) UIButton *modeSwitchButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *inputViewButton;


- (instancetype)initWithModeSwitchButton:(BOOL)hasAModeSwitchButton;

@end
