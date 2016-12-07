//
//  OSCUserItem.h
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@class OSCUserStatistics,OSCUserMoreInfo;
@interface OSCUserItem : NSObject

@property (nonatomic, assign) long id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSString *portrait;

@property (nonatomic, assign) UserGenderType gender;

@property (nonatomic, strong) NSString *desc;

@property (nonatomic, assign) UserRelationStatus relation;

@property (nonatomic, strong) OSCUserMoreInfo *more;

@property (nonatomic, strong) OSCUserStatistics *statistics;

@end


/** 他人动态主页用到的Item*/
@interface OSCUserHomePageItem : NSObject

@property (nonatomic, assign) UserGenderType gender;

@property (nonatomic, copy) NSString *portrait;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) OSCUserMoreInfo *more;

@property (nonatomic, assign) UserRelationStatus relation;

@property (nonatomic, strong) OSCUserStatistics *statistics;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *desc;

@end


@interface OSCUserStatistics : NSObject

@property (nonatomic, assign) NSInteger follow;

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSInteger answer;

@property (nonatomic, assign) NSInteger collect;

@property (nonatomic, assign) NSInteger tweet;

@property (nonatomic, assign) NSInteger discuss;

@property (nonatomic, assign) NSInteger fans;

@property (nonatomic, assign) NSInteger blog;

@end


@interface OSCUserMoreInfo : NSObject

@property (nonatomic, strong) NSString *expertise;

@property (nonatomic, strong) NSString *joinDate;

@property (nonatomic, strong) NSString *city;

@property (nonatomic, strong) NSString *platform;

@property (nonatomic, strong) NSString* company;

@property (nonatomic, strong) NSString* position;

@end

