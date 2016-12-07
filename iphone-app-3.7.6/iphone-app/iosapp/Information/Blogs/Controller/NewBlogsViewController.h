//
//  NewBlogsViewController.h
//  iosapp
//
//  Created by 李萍 on 16/7/11.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewBlogsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;
@property (weak, nonatomic) IBOutlet UIButton *hotButton;
@property (weak, nonatomic) IBOutlet UIButton *normalButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
