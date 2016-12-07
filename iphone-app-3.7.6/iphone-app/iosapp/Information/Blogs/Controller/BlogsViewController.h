//
//  BlogsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/30/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(NSUInteger, BlogsType)
{
    BlogTypeLatest,
    BlogTypeRecommended,
};

@interface BlogsViewController : OSCObjsViewController

- (instancetype)initWithBlogsType:(BlogsType)type;
- (instancetype)initWithUserID:(int64_t)userID;

@end
