//
//  OSCSearchViewController.h
//  iosapp
//
//  Created by 王恒 on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCSearchViewController : UIViewController

@end




@interface  SearchTitleBar : UIView

@property(nonatomic,copy)void(^btnClick)(NSInteger index);

-(instancetype)initWithFrame:(CGRect)frame WithTitles:(NSArray *)titles;

-(void)selectBtn:(UIButton *)btn;

@end
