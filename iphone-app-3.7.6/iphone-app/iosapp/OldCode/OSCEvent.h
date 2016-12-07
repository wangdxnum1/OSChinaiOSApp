//
//  OSCEvent.h
//  iosapp
//
//  Created by chenhaoxiang on 11/29/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import <UIKit/UIKit.h>

@interface OSCEvent : OSCBaseObject

// 主要信息
@property (nonatomic, assign) int64_t eventID;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSURL *tweetImg;

// 作者相关
@property (nonatomic, assign) int64_t authorID;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSURL *portraitURL;

// 其他信息
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, assign) int appclient;
@property (nonatomic, assign) int catalog;
@property (nonatomic, assign) int commentCount;

// 评论、回复相关
@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, assign) int objectType;
@property (nonatomic, assign) int objectCatalog;
@property (nonatomic, copy) NSString *objectTitle;
@property (nonatomic, strong) NSArray *objectReply;

@property (nonatomic, assign) BOOL hasAnImage;
@property (nonatomic, assign) BOOL hasReference;
@property (nonatomic, assign) BOOL shouleShowClientOrCommentCount;
@property (nonatomic, strong, readonly) NSMutableAttributedString *actionStr;
@property (nonatomic, strong) NSAttributedString *attributedCommentCount;

@property (nonatomic, assign) CGFloat cellHeight;

@end
