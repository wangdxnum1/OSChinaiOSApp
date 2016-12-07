//
//  OSCActivityFooterView.h
//  iosapp
//
//  Created by 王恒 on 16/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@protocol OSCActivityFooterDelegate <NSObject>

- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request;

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height;

@end

@interface OSCActivityFooterView : UIView

@property (nonatomic,strong) NSString *needLoad;
@property (nonatomic,assign) id<OSCActivityFooterDelegate> delegate;

@end
