//
//  OSCNewHotBlog.h
//  iosapp
//
//  Created by Holden on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OSCNewHotBlog : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, copy) NSString *href;
@property (nonatomic, assign) int commentCount;
@property (nonatomic, assign) int viewCount;
@property (nonatomic,assign) BOOL recommend;
@property (nonatomic,assign) BOOL original;
@property (nonatomic,assign) NSInteger type;

@property (nonatomic, copy) NSMutableAttributedString *attributedTitleString;

@end
