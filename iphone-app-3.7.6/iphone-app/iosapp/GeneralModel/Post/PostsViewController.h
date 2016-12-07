//
//  PostsViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCObjsViewController.h"

typedef NS_ENUM(int, PostsType)
{
    PostsTypeQA = 1,
    PostsTypeShare,
    PostsTypeSynthesis,
    PostsTypeCaree,
    PostsTypeSiteManager,
};

@interface PostsViewController : OSCObjsViewController

- (instancetype)initWithPostsType:(PostsType)type;

@end
