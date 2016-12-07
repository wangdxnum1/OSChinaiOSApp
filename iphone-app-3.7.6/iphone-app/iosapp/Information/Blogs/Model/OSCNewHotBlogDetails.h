//
//  OSCNewHotBlogDetails.h
//  iosapp
//
//  Created by 巴拉提 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCNewHotBlogDetails : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, copy) NSString *authorPortrait;
@property (nonatomic, strong) NSString *pubDate;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger viewCount;
@property (nonatomic, strong) NSString *href;
@property (nonatomic, assign) BOOL recommend;
@property (nonatomic, assign) BOOL original;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) NSInteger authorRelation;
@property (nonatomic, strong) NSString *abstract;
@property (nonatomic, strong) NSArray *abouts;
@property (nonatomic, strong) NSArray *comments;

@end
