//
//  OSCBaseObject.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-15.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@implementation OSCBaseObject

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    NSAssert(false, @"Over ride in subclasses");
    return nil;
}

- (instancetype)initWithTBXMLElement:(TBXMLElement*)element {
    NSAssert(false, @"Over ride in TBXML subclasses");
    return nil;
}

@end
