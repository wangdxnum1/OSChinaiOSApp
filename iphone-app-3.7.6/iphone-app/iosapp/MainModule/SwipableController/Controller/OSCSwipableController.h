//
//  OSCSwipableController.h
//  iosapp
//
//  Created by 李萍 on 2016/11/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCSwipableController : UIViewController

- (instancetype)initWithTitle:(NSString *)title
                       Titles:(NSArray *)titles
            subViewControllers:(NSArray *)subViewControllers
                  tabbarHidden:(BOOL)isHidden;

@end
