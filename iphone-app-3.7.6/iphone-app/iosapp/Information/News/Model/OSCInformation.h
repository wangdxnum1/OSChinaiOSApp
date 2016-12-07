//
//  OSCInformation.h
//  iosapp
//
//  Created by Graphic-one on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "enumList.h"

@interface OSCInformation : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* body;

@property (nonatomic,assign) NSInteger commentCount;

@property (nonatomic,assign) NSInteger viewCount;

@property (nonatomic,strong) NSString* author;

@property (nonatomic,assign) InformationType type;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) BOOL recommend;

@property (nonatomic,strong) NSString* pubDate;

@property (nonatomic,strong) NSMutableAttributedString* attributedBody;
//以下是布局信息
@property (nonatomic,assign) CGFloat rowHeight;

@end


