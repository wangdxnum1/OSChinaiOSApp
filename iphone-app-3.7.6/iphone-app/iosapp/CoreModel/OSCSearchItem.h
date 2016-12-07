//
//  OSCSearchItem.h
//  iosapp
//
//  Created by Graphic-one on 16/10/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@interface OSCSearchModel : NSObject   @end

/**搜索 < 软件-问答-博客-资讯类型 > 使用的Item*/
@interface OSCSearchItem : OSCSearchModel

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSString* author;

@property (nonatomic, strong) NSString* pubDate;

@property (nonatomic, strong) NSString* title;

@property (nonatomic, strong) NSString* body;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger viewCount;

@property (nonatomic, strong) NSString* href;

@property (nonatomic, assign) InformationType type;

@property (nonatomic, assign, getter=isRecommend) BOOL recommend;

@end

/** 寻找人使用的Item */
@class OSCUserMoreInfo , OSCUserStatistics;
@interface OSCSearchPeopleItem : OSCSearchModel

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* portrait;

@property (nonatomic, assign) UserGenderType gender;

@property (nonatomic, strong) NSString* desc;

@property (nonatomic, assign) UserRelationStatus relation;

@property (nonatomic, strong) OSCUserMoreInfo* more;

@property (nonatomic, strong) OSCUserStatistics* statistics;

@property (nonatomic, assign) InformationType type;

@end


