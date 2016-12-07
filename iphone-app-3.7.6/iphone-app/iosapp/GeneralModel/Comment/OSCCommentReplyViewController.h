//
//  OSCCommentReplyViewController.h
//  iosapp
//
//  Created by 李萍 on 2016/11/24.
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

@interface OSCCommentReplyViewController : UIViewController

- (instancetype)initWithCommentType:(CommentIdType)commentType sourceID:(NSInteger)sourceId;

@end
