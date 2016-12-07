//
//  OSCReference.m
//  iosapp
//
//  Created by ChanAetern on 2/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCReference.h"

@interface OSCReference ()

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *body;

@end

@implementation OSCReference

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _title = [[xml firstChildWithTag:@"refertitle"] stringValue];
        _body  = [[xml firstChildWithTag:@"referbody"] stringValue];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    OSCReference *referenceCopy = [OSCReference allocWithZone:zone];
    referenceCopy.title = _title;
    referenceCopy.body  = _body;
    
    return referenceCopy;
}

@end
