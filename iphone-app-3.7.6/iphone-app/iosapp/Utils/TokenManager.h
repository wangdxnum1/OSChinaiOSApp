//
//  TokenManager.h
//  iosapp
//
//  Created by Graphic-one on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 通过该key取"咨询"列表的nextToken*/
extern NSString* const Information_List_Key;
/** 通过该key取"博客"列表的nextToken*/
extern NSString* const Blog_List_Key;
/** 通过该key取"问答"列表的nextToken*/
extern NSString* const QandA_List_Key;
/** 通过该key取"活动"列表的nextToken*/
extern NSString* const Activity_List_Key;

typedef NS_ENUM(NSInteger , TokenType) {
    TokenTypeInformation,
    TokenTypeBlog,
    TokenTypeQandA,
    TokenTypeActivity
};

@interface TokenManager : NSObject

+ (NSString* )getTokenWithKey:(TokenType)type;

+ (BOOL)saveTokenWithKey:(TokenType)type newToken:(NSString* )token;

@end
