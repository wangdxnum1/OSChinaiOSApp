//¡
//  OSCNews.h
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

typedef NS_ENUM(NSUInteger, NewsType)
{
    NewsTypeStandardNews,
    NewsTypeSoftWare,
    NewsTypeQA,
    NewsTypeBlog
};

@interface OSCNews : OSCBaseObject

@property (nonatomic, assign) int64_t newsID;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *body;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, copy)   NSString *author;
@property (nonatomic, assign) int64_t authorID;
@property (nonatomic, assign) NewsType type;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *eventURL;
@property (nonatomic, copy) NSString *attachment;
@property (nonatomic, assign) int64_t authorUID2;

@property (nonatomic, strong) NSMutableAttributedString *attributedTittle;
@property (nonatomic, strong) NSAttributedString *attributedCommentCount;

@end





