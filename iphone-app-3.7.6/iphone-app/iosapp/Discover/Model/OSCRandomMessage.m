//
//  OSCRandomMessage.m
//  iosapp
//
//  Created by ChanAetern on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCRandomMessage.h"

@implementation OSCRandomMessage

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _type = [[[xml firstChildWithTag:@"randomtype"] numberValue] intValue];
        _randomMessageID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[[xml firstChildWithTag:@"title"] stringValue] copy];
        _detail = [[[xml firstChildWithTag:@"detail"] stringValue] copy];
        _author = [[[xml firstChildWithTag:@"author"] stringValue] copy];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _portraitURL = [NSURL URLWithString:[[[xml firstChildWithTag:@"image"] stringValue] copy]];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:@"pubDate"].stringValue];
        _commentCount = [[[xml firstChildWithTag:@"commentCount"] numberValue] intValue];
        _url = [NSURL URLWithString:[[[xml firstChildWithTag:@"url"] stringValue] copy]];
    }
    
    return self;
}

@end



@implementation OSCRandomMessageItem


@end




@implementation OSCRandomGift

@end










