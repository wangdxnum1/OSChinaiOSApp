//
//  OSCActivities.h
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@interface OSCActivities : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* body;

@property (nonatomic,strong) NSString* img;

@property (nonatomic,strong) NSString* startDate;

@property (nonatomic,strong) NSString* endDate;

@property (nonatomic,strong) NSString* pubDate;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) NSInteger applyCount;

@property (nonatomic,assign) ActivityStatus status;

@property (nonatomic,assign) ActivityType type;

/* 新增活动详情节点 */
@property (nonatomic, assign) ApplyStatus applyStatus;

@property (nonatomic, copy)   NSString *author;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy)   NSString *authorPortrait;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger viewCount;

@property (nonatomic, copy)   NSString *spot;//活动详细地址

@property (nonatomic, copy)   NSString *location;//活动位置坐标

@property (nonatomic, copy)   NSString *city;

@property (nonatomic, copy)   NSString *costDesc;//活动花费描述

@property (nonatomic, assign) BOOL favorite;

@property (nonatomic, strong) NSDictionary *remark;

@end
