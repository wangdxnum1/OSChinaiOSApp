//
//  OSCDiscuss.h
//  iosapp
//
//  Created by Graphic-one on 16/9/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,OSCDiscusOriginType){
    OSCDiscusOriginTypeLineNews = 0,
    OSCDiscusOriginTypeSoftWare = 1,
    OSCDiscusOriginTypeForum = 2,
    OSCDiscusOriginTypeBlog = 3,
    OSCDiscusOriginTypeTranslation = 4,
    OSCDiscusOriginTypeActivity = 5,
    OSCDiscusOriginTypeInfo = 6,
    OSCDiscusOriginTypeTweet = 100
};
/**
 *  0-链接新闻
 *  1-软件推荐
 *  2-讨论区帖子（问答）
 *  3-博客
 *  4-翻译文章
 *  5-活动类型
 *  6-资讯类型
 *  100-动弹（评论）类型
 */

@class OSCDiscusAuthor,OSCDiscussOrigin;
@interface OSCDiscuss : NSObject

@property (nonatomic,assign) NSInteger appClient;

@property (nonatomic,strong) OSCDiscusAuthor* author;

@property (nonatomic,assign) NSInteger commentCount;

@property (nonatomic,strong) NSString* content;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) OSCDiscussOrigin* origin;

@property (nonatomic,strong) NSString* pubDate;

@end


@interface OSCDiscusAuthor : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* portrait;

@end


@interface OSCDiscussOrigin : NSObject

@property (nonatomic,strong) NSString* desc;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,assign) OSCDiscusOriginType type;

@property (nonatomic,strong) NSString* href;

@end
