//
//  OSCQuesAnsDetailsContentView.h
//  iosapp
//
//  Created by Graphic-one on 16/11/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@class OSCQuestion;

@protocol OSCQuestionAnsDetailDelegate <NSObject>

- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request;

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height;

@end

@interface OSCQuesAnsDetailsContentView : UIView

@property (nonatomic,strong) OSCQuestion* question;

@property (nonatomic,assign) id<OSCQuestionAnsDetailDelegate> delegate;

@end
