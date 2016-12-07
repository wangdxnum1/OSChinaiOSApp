//
//  UIDevice+SystemInfo.h
//  iosapp
//
//  Created by Graphic-one on 16/8/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@interface UIDevice (SystemInfo)

+ (DeviceResolution) currentDeviceResolution;

+ (SystemVersion) currentSystemVersion;

@end
