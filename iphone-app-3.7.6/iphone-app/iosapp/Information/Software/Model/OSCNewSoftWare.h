//
//  OSCNewSoftWare.h
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCNewSoftWareAbouts;

@interface OSCNewSoftWare : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *extName;

@property (nonatomic, copy) NSString *logo;

@property (nonatomic, copy) NSString *body;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy) NSString *authorPortrait;

@property (nonatomic, assign) NSInteger authorRelation;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, copy) NSString *license;

@property (nonatomic, copy) NSString *homePage;

@property (nonatomic, copy) NSString *document;

@property (nonatomic, copy) NSString *download;

@property (nonatomic, copy) NSString *language;

@property (nonatomic, copy) NSString *supportOS;

@property (nonatomic, copy) NSString *collectionDate;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger viewCount;

@property (nonatomic, assign) BOOL favorite;

@property (nonatomic,assign) BOOL recommend;

@property (nonatomic, strong) NSArray<OSCNewSoftWareAbouts* > *abouts;

@end

@interface OSCNewSoftWareAbouts : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) NSInteger viewCount;

@end
