//
//  OSCPrivateChat.m
//  iosapp
//
//  Created by Graphic-one on 16/8/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPrivateChat.h"
#import "Config.h"
#import "Utils.h"
#import "OSCPrivateChatCell.h"

#define Allow_Time_Interval 60 * 5

@implementation OSCPrivateChat

- (void)setPubDate:(NSString *)pubDate{
    _pubDate = pubDate;
    
    _displayTimeTip = [TimeTipHelper shouldDisplayTimeTip:[self GA_DateWithString:_pubDate]];
}

- (void)setType:(NSInteger)type{
    _type = type;
    
    if (type == 1) {
        _privateChatType = OSCPrivateChatTypeText;
    }else if (type == 3){
        [ScrollToBottomHelper addReference];

        _privateChatType = OSCPrivateChatTypeImage;
        _imageFrame = (CGRect){{0,0},{PRIVATE_IMAGE_DEFAULT_W,PRIVATE_IMAGE_DEFAULT_H}};
        _popFrame = (CGRect){{0,0},{PRIVATE_IMAGE_DEFAULT_W + PRIVATE_POP_IMAGE_PADDING_LEFT + PRIVATE_POP_IMAGE_PADDING_RIGHT,PRIVATE_IMAGE_DEFAULT_H + PRIVATE_POP_IMAGE_PADDING_TOP + PRIVATE_POP_IMAGE_PADDING_BOTTOM}};
        _timeTipFrame = (CGRect){{0,0},{PRIVATE_TIME_TIP_W,PRIVATE_TIME_TIP_H}};
    }else if (type == 5){
        _privateChatType = OSCPrivateChatTypeFile;
        _fileFrame = (CGRect){{0,0},{PRIVATE_FILE_TIP_W,PRIVATE_FILE_TIP_H}};
        _popFrame = (CGRect){{0,0},{PRIVATE_FILE_TIP_W + PRIVATE_POP_FILE_PADDING_LEFT + PRIVATE_POP_FILE_PADDING_RIGHT,PRIVATE_FILE_TIP_H + PRIVATE_POP_FILE_PADDING_TOP + PRIVATE_POP_FILE_PADDING_BOTTOM}};
        _timeTipFrame = (CGRect){{0,0},{PRIVATE_TIME_TIP_W,PRIVATE_TIME_TIP_H}};
    }else{
        _privateChatType = NSNotFound;
    }
}

- (void)setContent:(NSString *)content{
    _content = content;

    if (_content != nil) {
        NSAttributedString* string =[Utils contentStringFromRawString:_content];
        CGSize size = [string.string boundingRectWithSize:(CGSize){PRIVATE_MAX_WIDTH,MAXFLOAT} options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:CHAT_TEXT_FONT_SIZE]} context:nil].size;
        if(size.width < 22){ size.width = 22;}
        _textFrame = (CGRect){{0,0},size};
        _popFrame = (CGRect){{0,0},{size.width + PRIVATE_POP_PADDING_LEFT + PRIVATE_POP_PADDING_RIGHT,size.height + PRIVATE_POP_PADDING_TOP + PRIVATE_POP_PADDING_BOTTOM}};
        _timeTipFrame = (CGRect){{0,0},{PRIVATE_TIME_TIP_W,PRIVATE_TIME_TIP_H}};
    }
}


#pragma mark --- string -> date
- (NSDate* )GA_DateWithString:(NSString* )dateStr{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";//"2016-08-31 16:49:50”
    NSDate *time_date = [format dateFromString:dateStr];
    return time_date;
}
@end


@implementation OSCSender

- (void)setId:(NSInteger)id{
    _id = id;
    
    if([Config getOwnID] == _id){
        _bySelf = YES;
    }else{
        _bySelf = NO;
    }
}

@end



/** 处理timeTip的小工具类 与model绑定*/
@interface TimeTipHelper()
@property (nonatomic,strong) NSDate* updateTime;
@end

@implementation TimeTipHelper

static TimeTipHelper* _timeHelper;
+ (instancetype)shareTimeTipHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _timeHelper = [TimeTipHelper new];
        _timeHelper.updateTime = nil;
    });
    return _timeHelper;
}

+ (BOOL)shouldDisplayTimeTip:(NSDate *)date{
    TimeTipHelper* timeHelper = [self shareTimeTipHelper];
    
    if (timeHelper.updateTime == nil) {
        timeHelper.updateTime = date;
        return YES;
    }
    
    NSTimeInterval timeInterval = [date timeIntervalSinceDate:timeHelper.updateTime];
    if (timeInterval > Allow_Time_Interval) {
        timeHelper.updateTime = date;
        return YES;
    }else{
        return NO;
    }
}

+ (void)resetTimeTipHelper{
    TimeTipHelper* timeHelper = [self shareTimeTipHelper];
    timeHelper.updateTime = nil;
}
@end



/** 处理滚动底部的小工具类 与单次解析绑定*/
@interface ScrollToBottomHelper ()
@property (nonatomic,assign) NSInteger count;
@end

@implementation ScrollToBottomHelper

static ScrollToBottomHelper* _shareScrollToBottomHelper;
+ (instancetype)shareScrollToBottomHelper{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareScrollToBottomHelper = [ScrollToBottomHelper new];
    });
    return _shareScrollToBottomHelper;
}

+ (void)addReference{
    _shareScrollToBottomHelper.count += 1;
}

+ (NSInteger)imagesCount{
    return _shareScrollToBottomHelper.count;
}

+ (void)resetScrollToBottomHelper{
    _shareScrollToBottomHelper.count = 0 ;
}

@end



