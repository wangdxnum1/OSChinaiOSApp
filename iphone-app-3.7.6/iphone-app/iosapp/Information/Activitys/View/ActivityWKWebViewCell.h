//
//  ActivityWKWebViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/10/20.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityWKWebViewCell,WKWebView,WKNavigation;
@protocol ActivityWKWebViewCellDelegate <NSObject>

- (void)ActivityWKWebViewCellDidFinshLoadHTML:(ActivityWKWebViewCell* )activityWKWebViewCell
                                      webView:(WKWebView *)webView
                                   navigation:(WKNavigation *)navigation
                                webViewHeight:(CGFloat)webViewHeight;

@end

@interface ActivityWKWebViewCell : UITableViewCell

@property (nonatomic,strong) NSString* HTML_String;

@property (nonatomic,weak) id<ActivityWKWebViewCellDelegate> delegate;

@end
