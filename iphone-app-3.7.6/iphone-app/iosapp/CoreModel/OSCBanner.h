//
//  OSCBanner.h
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@interface OSCBanner : NSObject

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* detail;

@property (nonatomic,strong) NSString* img;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) InformationType type;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* time;

@end
