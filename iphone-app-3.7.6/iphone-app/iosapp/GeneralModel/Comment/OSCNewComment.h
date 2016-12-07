//
//  OSCNewComment.h
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSCUserItem.h"

@class OSCNewCommentRefer, OSCNewCommentReply;

@interface OSCNewComment : NSObject

@property (nonatomic, assign) long id;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger appClient;
@property (nonatomic, assign) NSInteger vote;
@property (nonatomic, assign) NSInteger voteState;
@property (nonatomic, assign) BOOL best;

@property (nonatomic, strong) OSCNewCommentRefer *refer;
@property (nonatomic, strong) NSArray <OSCNewCommentReply* >* reply;

//old
@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, copy) NSString *authorPortrait;
@property (nonatomic, strong) NSString *author;

@end


//引用
@interface OSCNewCommentRefer : NSObject

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, strong) OSCNewCommentRefer *refer;

@end


//回复
@interface OSCNewCommentReply : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, copy) NSString *authorPortrait;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;

@end
