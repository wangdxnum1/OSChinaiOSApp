//
//  OSCSoftwareDetails.h
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCSoftwareDetails : OSCBaseObject

@property (nonatomic, assign) int64_t softwareID;
@property (nonatomic, assign) NSInteger authorID;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) BOOL isRecommended;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *extensionTitle;
@property (nonatomic, copy) NSString *license;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *os;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *recordTime;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *homepageURL;
@property (nonatomic, copy) NSString *documentURL;
@property (nonatomic, copy) NSString *downloadURL;
@property (nonatomic, copy) NSString *logoURL;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) int tweetCount;

@property (nonatomic, copy) NSString *html;

@end
