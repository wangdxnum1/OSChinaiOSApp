//
//  OSCTweetItem.h
//  iosapp
//
//  Created by Graphic-one on 16/7/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

struct MultipleImageViewFrame {
    int line;
    int row;
    CGRect frame;
};
typedef struct MultipleImageViewFrame MultipleImageViewFrame;

@class OSCTweetAuthor,OSCTweetCode,OSCTweetAudio,OSCTweetImages;

/** 动弹列表使用的Item */
@interface OSCTweetItem : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger appClient;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, strong) OSCTweetAuthor *author;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger likeCount;

@property (nonatomic, strong) NSArray<OSCTweetAudio *> *audio;

@property (nonatomic, strong) OSCTweetCode *code;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, strong) NSArray<OSCTweetImages *> *images;

@property (nonatomic, assign) BOOL liked;

@property (nonatomic, copy) NSString *content;

/** 以下是布局信息*/
@property (nonatomic,assign) CGRect descTextFrame;///< 无图 单图 多图用到

@property (nonatomic,assign) CGRect imageFrame;///< 单图用到

@property (nonatomic,assign) MultipleImageViewFrame multipleFrame;///< 多图用到

@property (nonatomic,assign) CGFloat rowHeight;

/** 当model解析完成之后调用该方法以获取异步布局信息 */
- (void)calculateLayout;

@end

#pragma mark -
#pragma mark --- 动弹作者
@interface OSCTweetAuthor : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portrait;

@end

#pragma mark -
#pragma mark --- 动弹Code
@interface OSCTweetCode : NSObject

@property (nonatomic, copy) NSString *brush;

@property (nonatomic, copy) NSString *content;

@end

#pragma mark -
#pragma mark --- 动弹音频 && 视频
@interface OSCTweetAudio : NSObject

@property (nonatomic, copy) NSString *href;

@property (nonatomic, assign) NSInteger timeSpan;

@end

#pragma mark -
#pragma mark --- 动弹图片
@interface OSCTweetImages : NSObject

@property (nonatomic, copy) NSString *thumb;//小图

@property (nonatomic, copy) NSString *href;//大图

@property (nonatomic, assign) NSInteger w;//原图宽

@property (nonatomic, assign) NSInteger h;//原图高

@end


#pragma mark - 推荐话题
/** 推荐话题列表使用到Item */
@interface OSCTweetTopicItem : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* desc;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,strong) NSString* pubDate;

@property (nonatomic,assign) NSInteger joinCount;

@property (nonatomic,strong) NSArray<OSCTweetItem* >* items;

@end


