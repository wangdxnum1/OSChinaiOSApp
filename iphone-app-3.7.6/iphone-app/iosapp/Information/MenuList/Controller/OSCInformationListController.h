//
//  OSCInformationListController.h
//  iosapp
//
//  Created by Graphic-one on 16/10/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCMenuItem;

@interface OSCInformationListController : UIViewController

+ (instancetype)InformationListWithListModel:(OSCMenuItem* )model;

@end
