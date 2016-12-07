//
//  OSCTweet.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import <UIKit/UIKit.h>

@interface OSCTweet : OSCBaseObject

@property (nonatomic, assign) int64_t tweetID;
@property (nonatomic, copy) NSURL *portraitURL;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) int64_t authorID;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, assign) int appclient;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, strong) NSString *pubDateString;
@property (nonatomic, assign) BOOL hasAnImage;
@property (nonatomic, strong) NSURL *smallImgURL;
@property (nonatomic, strong) NSURL *bigImgURL;
@property (nonatomic, copy) NSString *attach;

@property (nonatomic, assign) int likeCount;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, copy) NSMutableArray *likeList;
@property (nonatomic, copy) NSMutableAttributedString *likersString;
@property (nonatomic, copy) NSMutableAttributedString *likersDetailString;
@property (nonatomic, strong) NSAttributedString *attributedCommentCount;
@property (nonatomic, assign) CGFloat cellHeight;


@end
