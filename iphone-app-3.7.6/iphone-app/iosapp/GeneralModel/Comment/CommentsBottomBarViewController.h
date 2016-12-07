//
//  CommentsBottomBarViewController.h
//  iosapp
//
//  Created by ChanAetern on 1/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BottomBarViewController.h"
#import "CommentsViewController.h"

@interface CommentsBottomBarViewController : BottomBarViewController

- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID;

@end
