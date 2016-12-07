//
//  FeedBackViewController.h
//  iosapp
//
//  Created by 李萍 on 16/1/11.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

@interface FeedBackViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *programErrorView;
@property (weak, nonatomic) IBOutlet UIButton *recommentFunctionView;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *feedbackTextView;
@property (weak, nonatomic) IBOutlet UIImageView *printscrenImagView;

@end
