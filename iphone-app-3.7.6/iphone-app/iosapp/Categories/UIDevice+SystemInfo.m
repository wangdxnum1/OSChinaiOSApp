//
//  UIDevice+SystemInfo.m
//  iosapp
//
//  Created by Graphic-one on 16/8/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UIDevice+SystemInfo.h"
#import <sys/utsname.h>

@implementation UIDevice (SystemInfo)

+ (DeviceResolution)currentDeviceResolution{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone3,1"]) return Device_iPhone_4;
    if ([platform isEqualToString:@"iPhone3,2"]) return Device_iPhone_4;
    if ([platform isEqualToString:@"iPhone3,3"]) return Device_iPhone_4;
    if ([platform isEqualToString:@"iPhone4,1"]) return Device_iPhone_4s;
    if ([platform isEqualToString:@"iPhone5,1"]) return Device_iPhone_5;
    if ([platform isEqualToString:@"iPhone5,2"]) return Device_iPhone_5;
    if ([platform isEqualToString:@"iPhone5,3"]) return Device_iPhone_5c;
    if ([platform isEqualToString:@"iPhone5,4"]) return Device_iPhone_5c;
    if ([platform isEqualToString:@"iPhone6,1"]) return Device_iPhone_5s;
    if ([platform isEqualToString:@"iPhone6,2"]) return Device_iPhone_5s;
    if ([platform isEqualToString:@"iPhone7,1"]) return Device_iPhone_6p;
    if ([platform isEqualToString:@"iPhone7,2"]) return Device_iPhone_6;
    if ([platform isEqualToString:@"iPhone8,1"]) return Device_iPhone_6s;
    if ([platform isEqualToString:@"iPhone8,2"]) return Device_iPhone_6sp;
    if ([platform isEqualToString:@"iPhone8,4"]) return Device_iPhone_se;
    if ([platform isEqualToString:@"iPhone9,1"]) return Device_iPhone_7;
    if ([platform isEqualToString:@"iPhone9,2"]) return Device_iPhone_7p;
    
    return Device_Simulator;
}

+ (SystemVersion)currentSystemVersion{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion - 10 >= 0) return Version_iOS10;
    if (systemVersion - 9  >= 0) return Version_iOS9;
    if (systemVersion - 8  >= 0) return Version_iOS8;
    if (systemVersion - 7  >= 0) return Version_iOS7;
    
    return Version_noSupport;
}




@end
