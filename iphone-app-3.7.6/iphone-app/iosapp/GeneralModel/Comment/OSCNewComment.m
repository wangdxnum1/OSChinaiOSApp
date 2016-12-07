//
//  OSCNewComment.m
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNewComment.h"
//#import "OSCModelHandler.h"

@implementation OSCNewComment

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"reply" : [OSCNewCommentReply class],
             
             };
}

@end

//引用
@implementation OSCNewCommentRefer

@end


//回复
@implementation OSCNewCommentReply

@end
