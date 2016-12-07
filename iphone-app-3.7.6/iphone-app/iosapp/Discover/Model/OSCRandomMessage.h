//
//  OSCRandomMessage.h
//  iosapp
//
//  Created by ChanAetern on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

//XML Parse Model

typedef NS_ENUM(int, RandomType)
{
    RandomTypeNews = 1,
    RandomTypeBlog,
    RandomTypeSoftware,
};

@interface OSCRandomMessage : OSCBaseObject

@property (nonatomic, readonly, assign) RandomType type;
@property (nonatomic, readonly, assign) int64_t randomMessageID;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *detail;
@property (nonatomic, readonly, copy) NSString *author;
@property (nonatomic, readonly, assign) int64_t authorID;
@property (nonatomic, readonly, strong) NSURL *portraitURL;
@property (nonatomic, readonly, strong) NSDate *pubDate;
@property (nonatomic, readonly, assign) int commentCount;
@property (nonatomic, readonly, strong) NSURL *url;

@end



//JSON Parse Model (摇一摇综合)

typedef NS_ENUM(NSInteger,OSCRandomMessageType){
    OSCRandomMessageTypeLinkNews = 0 ,
    OSCRandomMessageTypeSoftware ,
    OSCRandomMessageTypeDiscuss ,
    OSCRandomMessageTypeBlog ,
    OSCRandomMessageTypeTranslation ,
    OSCRandomMessageTypeActivity ,
    OSCRandomMessageTypeNew
};

@interface OSCRandomMessageItem : NSObject

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* detail;

@property (nonatomic,strong) NSString* img;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) OSCRandomMessageType type;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* pubDate;

@end


//JSON Parse Model (摇一摇抽奖_礼物)

@interface OSCRandomGift : NSObject

@property (nonatomic,strong) NSString* name;

@property (nonatomic,strong) NSString* pic;

@property (nonatomic,strong) NSString* href;

@end





