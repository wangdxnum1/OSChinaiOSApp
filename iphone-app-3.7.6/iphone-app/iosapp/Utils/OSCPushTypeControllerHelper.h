//
//  OSCPushTypeControllerHelper.h
//  iosapp
//
//  Created by Graphic-one on 16/8/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "enumList.h"

@class OSCDiscussOrigin,OSCRandomMessageItem,OSCSearchModel,OSCListItem;
@interface OSCPushTypeControllerHelper : NSObject

+ (UIViewController* )pushControllerWithDiscussOriginType:(OSCDiscussOrigin* )discussOrigin;

+ (UIViewController* )pushControllerWithRandomNewsType:(OSCRandomMessageItem* )randomMessageItem;

+ (UIViewController *)pushControllerWithSearchItem:(__kindof OSCSearchModel* )searchModel;

+ (UIViewController* )pushControllerWithListItem:(OSCListItem* )listItem;


/** 通用跳转handle */
+ (UIViewController* )pushControllerGeneralWithType:(InformationType)type
                                    detailContentID:(NSInteger)id;

@end
