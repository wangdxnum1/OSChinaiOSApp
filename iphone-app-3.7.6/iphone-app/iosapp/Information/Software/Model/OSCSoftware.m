//
//  OSCSoftware.m
//  iosapp
//
//  Created by chenhaoxiang on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCSoftware.h"

static NSString * const kName = @"name";
static NSString * const kDescription = @"description";
static NSString * const kURL = @"url";

@implementation OSCSoftware

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _name = [[xml firstChildWithTag:kName] stringValue];
        _softwareDescription = [[xml firstChildWithTag:kDescription] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:kURL] stringValue]];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    return NO;
}

@end
