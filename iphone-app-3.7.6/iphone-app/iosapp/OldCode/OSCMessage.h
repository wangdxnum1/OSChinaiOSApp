//
//  OSCMessage.h
//  iosapp
//
//  Created by ChanAetern on 12/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCMessage : OSCBaseObject

@property (nonatomic, readonly, assign) int64_t messageID;
@property (nonatomic, readonly, strong) NSURL *portraitURL;
@property (nonatomic, readonly, assign) int64_t friendID;
@property (nonatomic, readonly, copy) NSString *friendName;
@property (nonatomic, readonly, assign) int64_t senderID;
@property (nonatomic, readonly, copy) NSString *senderName;
@property (nonatomic, readonly, copy) NSString *content;
@property (nonatomic, readonly, assign) int messageCount;
@property (nonatomic, readonly, strong) NSDate *pubDate;

@end
