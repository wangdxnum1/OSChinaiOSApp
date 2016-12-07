//
//  OSCInformationDetails.h
//  iosapp
//
//  Created by Holden on 16/6/21.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCInformationDetails : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *originalTitle;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) int64_t authorId;
@property (nonatomic, copy) NSString *authorPortrait;
@property (nonatomic) NSInteger authorRelation;
@property (nonatomic, strong) NSString *pubDate;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, assign) int viewCount;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, strong) NSArray *abouts;
@property (nonatomic,strong) NSDictionary *software;

@end
