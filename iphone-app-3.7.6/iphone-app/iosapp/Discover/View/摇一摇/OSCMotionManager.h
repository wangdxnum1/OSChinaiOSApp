//
//  OSCMotionManager.h
//  iosapp
//
//  Created by Graphic-one on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMMotionManager;
@interface OSCMotionManager : NSObject

+ (CMMotionManager* )shareMotionManager;

@end
