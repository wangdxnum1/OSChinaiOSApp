//
//  OSCFavorite.m
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCFavorite.h"

static NSString * const kObjID = @"objid";
static NSString * const kType = @"type";
static NSString * const kTitle = @"title";
static NSString * const kURL = @"url";

@implementation OSCFavorite

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _objectID = [[[xml firstChildWithTag:kObjID] numberValue] longLongValue];
        _type = [[[xml firstChildWithTag:kType] numberValue] intValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _objectID == ((OSCFavorite *)object).objectID;
    }
    return NO;
}

@end
