//
//  QuesAnsViewController.h
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuesAnsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView   *buttonView;
@property (weak, nonatomic) IBOutlet UIView *buttonViewLine;
@property (nonatomic, weak) IBOutlet UIButton *askQuesButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *synthButton;
@property (nonatomic, weak) IBOutlet UIButton *jobButton;
@property (nonatomic, weak) IBOutlet UIButton *officeButton;


@end
