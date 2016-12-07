//
//  OSCReply.h
//  iosapp
//
//  Created by ChanAetern on 2/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCReply : OSCBaseObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *author;
@property (nonatomic, readonly, strong) NSDate *pubDate;
@property (nonatomic, readonly, copy) NSString *content;

@end
