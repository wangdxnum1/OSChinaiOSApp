//
//  NewCommentListViewController.h
//  iosapp
//
//  Created by 李萍 on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CommentIdType)
{
    CommentIdTypeForQuestion = 2,
    CommentIdTypeForBlog,
    CommentIdTypeForTranslate,
    CommentIdTypeForActivity,
    CommentIdTypeForNews,
};

@interface NewCommentListViewController : UIViewController

- (instancetype)initWithCommentType:(CommentIdType)commentType sourceID:(NSInteger)sourceId;

@end
