//
//  OSCUser.h
//  iosapp
//
//  Created by chenhaoxiangs on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCUser : OSCBaseObject

@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int followersCount;
@property (nonatomic, assign) int fansCount;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int favoriteCount;
@property (nonatomic, assign) int relationship;
@property (nonatomic, strong) NSURL *portraitURL;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *developPlatform;
@property (nonatomic, copy) NSString *expertise;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, strong) NSDate *joinTime;
@property (nonatomic, strong) NSDate *latestOnlineTime;
@property (nonatomic, readwrite, copy) NSString *pinyin; //拼音
@property (nonatomic, readwrite, copy) NSString *pinyinFirst; //拼音首字母

@property (nonatomic, copy) NSString *desc;//描述
@property (nonatomic, assign) int tweetCount;//动弹数


@end
