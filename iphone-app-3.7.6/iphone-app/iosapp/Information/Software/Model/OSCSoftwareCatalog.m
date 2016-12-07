//
//  OSCSoftwareCatalog.m
//  iosapp
//
//  Created by chenhaoxiang on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCSoftwareCatalog.h"

static NSString * const kName = @"name";
static NSString * const kTag = @"tag";

@interface OSCSoftwareCatalog ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) int tag;

@end

@implementation OSCSoftwareCatalog

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _name = [[xml firstChildWithTag:kName] stringValue];
        _tag = [[[xml firstChildWithTag:kTag] numberValue] intValue];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    return NO;
}

@end
