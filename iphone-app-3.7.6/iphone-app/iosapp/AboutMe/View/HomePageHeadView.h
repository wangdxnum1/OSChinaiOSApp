//
//  HomePageHeadView.h
//  iosapp
//
//  Created by 李萍 on 16/8/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCanvasView.h"
#import "HomeButtonView.h"

@class QuartzCanvasView;
@interface HomePageHeadView : UIView

@property (nonatomic, weak) QuartzCanvasView *drawView;;

@property (nonatomic, strong) UIImageView *userPortrait;
@property (nonatomic, strong) UIImageView *genderImageView;
@property (nonatomic, strong)  UILabel *nameLabel;
@property (nonatomic, strong)  UILabel *creditLabel;
@property (nonatomic, strong) HomeButtonView *buttonView;

@end
