//
//  WKDelegateController.h
//  iosapp
//
//  Created by Graphic-one on 16/10/20.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol WKDelegate <NSObject>
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
@end

@interface WKDelegateController : UIViewController <WKScriptMessageHandler>

@property (weak , nonatomic) id<WKDelegate> delegate;

@end
