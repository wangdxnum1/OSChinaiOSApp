//
//  OSCMessage.m
//  iosapp
//
//  Created by ChanAetern on 12/12/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCMessage.h"

@interface OSCMessage ()

@property (nonatomic, readwrite, assign) int64_t messageID;
@property (nonatomic, readwrite, strong) NSURL *portraitURL;
@property (nonatomic, readwrite, assign) int64_t friendID;
@property (nonatomic, readwrite, copy) NSString *friendName;
@property (nonatomic, readwrite, assign) int64_t senderID;
@property (nonatomic, readwrite, copy) NSString *senderName;
@property (nonatomic, readwrite, copy) NSString *content;
@property (nonatomic, readwrite, assign) int messageCount;
@property (nonatomic, readwrite, strong) NSDate *pubDate;

@end

@implementation OSCMessage

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _messageID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:@"portrait"] stringValue]];
        _friendID = [[[xml firstChildWithTag:@"friendid"] numberValue] longLongValue];
        _friendName = [[xml firstChildWithTag:@"friendname"] stringValue];
        _senderID = [[[xml firstChildWithTag:@"senderid"] numberValue] longLongValue];
        _senderName = [[xml firstChildWithTag:@"sender"] stringValue];
        _content = [[xml firstChildWithTag:@"content"] stringValue];
        _messageCount = [[[xml firstChildWithTag:@"messageCount"] numberValue] intValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:@"pubDate"].stringValue];
    }
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _messageID == ((OSCMessage *)object).messageID;
    }
    
    return NO;
}


@end
