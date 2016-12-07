//
//  BottomBarViewController.h
//  iosapp
//
//  Created by ChanAetern on 11/19/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditingBar.h"
#import "OperationBar.h"

@class EmojiPageVC;

@interface BottomBarViewController : UIViewController

@property (nonatomic, strong) EditingBar *editingBar;
@property (nonatomic, strong) OperationBar *operationBar;
@property (nonatomic, strong) NSLayoutConstraint *editingBarYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *editingBarHeightConstraint;

@property (nonatomic, strong) UIImage *image;//

- (instancetype)initWithModeSwitchButton:(BOOL)hasAModeSwitchButton;
- (instancetype)initWithPhotoButton:(BOOL)hasPhotoButton;

- (void)sendContent;//发送信息
- (void)updateInputBarHeight;
- (void)hideEmojiPageView;

@end
