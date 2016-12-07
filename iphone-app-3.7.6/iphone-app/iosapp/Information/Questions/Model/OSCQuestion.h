//
//  OSCQuestion.h
//  iosapp
//
//  Created by 李萍 on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,OSCQuestionType){
    OSCQuestionTypeDefault = 1,
    OSCQuestionTypeShare = 2,
    OSCQuestionTypeComprehensive = 3,
    OSCQuestionTypeJob = 4,
    OSCQuestionTypeAffair = 5
};
/**
 *  1: 提问
 *  2: 分享
 *  3: 综合
 *  4: 职业
 *  5: 站务
 */

@interface OSCQuestion : NSObject

@property (nonatomic, assign) NSInteger Id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *body;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy) NSString *authorPortrait;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger viewCount;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, assign) BOOL favorite;

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic,assign) OSCQuestionType type;

@end
