//
//  OSCSearchResult.m
//  iosapp
//
//  Created by ChanAetern on 1/22/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCSearchResult.h"

@implementation OSCSearchResult

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _objectID          = [[[xml firstChildWithTag:@"objid"] numberValue] longLongValue];
        _type              = [[[xml firstChildWithTag:@"type"] stringValue] copy];
        _title             = [[[xml firstChildWithTag:@"title"] stringValue] copy];
        _author            = [[[xml firstChildWithTag:@"author"] stringValue] copy];
        _objectDescription = [[[xml firstChildWithTag:@"description"] stringValue] copy];
        _url               = [NSURL URLWithString:[xml firstChildWithTag:@"url"].stringValue];
        _pubDate           = [NSDate dateFromString:[xml firstChildWithTag:@"pubDate"].stringValue];
    }
    
    return self;
}



- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _objectID == ((OSCSearchResult *)object).objectID;
    }
    
    return NO;
}


@end
