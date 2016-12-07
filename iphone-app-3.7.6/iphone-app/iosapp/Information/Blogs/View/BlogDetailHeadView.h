//
//  BlogDetailHeadView.h
//  iosapp
//
//  Created by 李萍 on 2016/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"

@class IMYWebView;
@interface BlogDetailHeadView : UIView

@property (nonatomic, strong) UIButton *relationButton;
@property (nonatomic, strong) IMYWebView *webView;

@property (nonatomic, strong) OSCBlogDetail *blogDetail;

@end
