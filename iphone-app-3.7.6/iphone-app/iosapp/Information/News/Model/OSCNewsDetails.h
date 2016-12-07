//
//  OSCNewsDetails.h
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCNewsDetails : OSCBaseObject

@property (nonatomic, assign) int64_t newsID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) ino64_t authorID;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, copy) NSURL *softwareLink;
@property (nonatomic, copy) NSString *softwareName;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, strong) NSArray *relatives;

@property (nonatomic, strong) NSString *html;

@end
