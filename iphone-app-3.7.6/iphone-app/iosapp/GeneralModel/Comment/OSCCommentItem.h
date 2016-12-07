//
//  OSCCommentItem.h
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSCUserItem.h"
#import "OSCReference.h"
#import "OSCReply.h"
#import "TeamMember.h"
#import <UIKit/UIKit.h>

@class OSCCommentItemRefer, OSCCommentItemReply;
@interface OSCCommentItem : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) OSCUserItem *author;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) int appClient;
/** new comment_list **/
@property (nonatomic, assign) NSInteger vote;
@property (nonatomic, assign) NSInteger voteState;
@property (nonatomic, assign) BOOL best;

@property (nonatomic, strong) NSArray <OSCCommentItemRefer* >* refer;
@property (nonatomic, strong) NSArray <OSCCommentItemReply* >*reply;
/** new comment_list **/

//新接口未用到的属性，如需用更改属性名与后台返回名字相同

@property (nonatomic, strong) NSArray *references;
@property (nonatomic, strong) NSArray *replies;

+ (NSAttributedString *)attributedTextFromReplies:(NSArray *)replies;
@end


//引用
@interface OSCCommentItemRefer : NSObject

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;

@end


//回复
@interface OSCCommentItemReply : NSObject

@property (nonatomic, assign) long id;
@property (nonatomic, strong) OSCUserItem *author;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;

@end
