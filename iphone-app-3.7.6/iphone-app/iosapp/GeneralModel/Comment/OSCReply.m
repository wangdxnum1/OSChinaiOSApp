//
//  OSCReply.m
//  iosapp
//
//  Created by ChanAetern on 2/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCReply.h"

@interface OSCReply ()

@property (nonatomic, readwrite, copy) NSString *author;
@property (nonatomic, readwrite, strong) NSDate *pubDate;
@property (nonatomic, readwrite, copy) NSString *content;

@end

@implementation OSCReply

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _author  = [[xml firstChildWithTag:@"rauthor"] stringValue];
        _pubDate = [NSDate dateFromString:[[xml firstChildWithTag:@"rpubDate"] stringValue]];
        _content = [[xml firstChildWithTag:@"rcontent"] stringValue];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    OSCReply *replyCopy = [OSCReply allocWithZone:zone];
    replyCopy.author  = _author;
    replyCopy.pubDate = _pubDate;
    replyCopy.content = _content;
    
    return replyCopy;
}

@end
