//
//  ActivitySignUpViewController.h
//  iosapp
//
//  Created by 李萍 on 15/3/3.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivitySignUpViewController : UIViewController

@property (nonatomic, readwrite, assign) int64_t eventId;
@property (nonatomic, copy) NSString *remarkTipStr;
@property (nonatomic, strong) NSArray *remarkCitys;

@end
