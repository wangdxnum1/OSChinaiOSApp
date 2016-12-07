//
//  OSCPrivateChat.h
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger,OSCPrivateChatType){
    OSCPrivateChatTypeText = 1,
    OSCPrivateChatTypeImage = 3,
    OSCPrivateChatTypeFile = 5
};

@class OSCSender;
@interface OSCPrivateChat : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) OSCSender *sender;

@property (nonatomic, copy) NSString *resource;

@property (nonatomic,assign) OSCPrivateChatType privateChatType;

//以下是布局信息
@property (nonatomic,assign) CGFloat rowHeight;///< 整体行高 全部消息类型都用到

@property (nonatomic,assign) CGRect popFrame;///< 气泡大小 全部消息类型都用到

@property (nonatomic,assign) CGRect timeTipFrame;///< 时间提示 全部消息类型都用到

@property (nonatomic,assign) CGRect textFrame;///< 文本消息类型

@property (nonatomic,assign) CGRect imageFrame;///< 图片消息类型

@property (nonatomic,assign) CGRect fileFrame;///< 文件消息类型

@property (nonatomic,assign,getter=isDisplayTimeTip) BOOL displayTimeTip;

@end

@interface OSCSender : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@property (nonatomic,assign,getter=isBySelf) BOOL bySelf;

@end



/** 处理timeTip的小工具类 与model绑定*/
@interface TimeTipHelper : NSObject

+ (void)resetTimeTipHelper;//每次私信对话model解析完之后调用

+ (BOOL)shouldDisplayTimeTip:(NSDate* )date;

@end

/** 处理滚动底部的小工具类 与单次解析绑定*/
@interface ScrollToBottomHelper : NSObject

+ (void)addReference;//引用计数加一

+ (NSInteger)imagesCount;//获取单次解析包含的图片数目

+ (void)resetScrollToBottomHelper;//归零重置

@end

