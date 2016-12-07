//
//  OSCMyTweetLikeList.h
//  iosapp
//
//  Created by 李萍 on 15/4/9.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCMyTweetLikeList : OSCBaseObject

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, assign) int64_t userID;
@property (nonatomic, readwrite, strong) NSURL *portraitURL;

@property (nonatomic, assign) int64_t tweetId;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *author;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, copy) NSMutableAttributedString *authorAndBody;

@end
