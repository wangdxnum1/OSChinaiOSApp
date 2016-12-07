//
//  OSCMotionManager.m
//  iosapp
//
//  Created by Graphic-one on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMotionManager.h"
#import <CoreMotion/CoreMotion.h>


@implementation OSCMotionManager

static CMMotionManager* _shareMotionManager;
+ (CMMotionManager *)shareMotionManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareMotionManager = [CMMotionManager new];
    });
    return _shareMotionManager;
}

@end
