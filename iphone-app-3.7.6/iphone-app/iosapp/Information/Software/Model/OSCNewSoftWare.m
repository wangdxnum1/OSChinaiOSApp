//
//  OSCNewSoftWare.m
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNewSoftWare.h"
#import <MJExtension.h>

@implementation OSCNewSoftWare

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"abouts" : [OSCNewSoftWareAbouts class]
             };
}

@end

@implementation OSCNewSoftWareAbouts

@end