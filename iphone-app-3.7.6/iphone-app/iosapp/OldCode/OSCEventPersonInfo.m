//
//  OSCEventPersonInfo.m
//  iosapp
//
//  Created by 李萍 on 15/3/6.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCEventPersonInfo.h"

static NSString * const kUserID = @"uid";
static NSString * const kUserName = @"name";
static NSString * const kPortrait = @"portrait";
static NSString * const kCompany = @"company";
static NSString * const kJob = @"job";

@implementation OSCEventPersonInfo

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _userID = [[[xml firstChildWithTag:kUserID] numberValue] intValue];
    _userName = [[[xml firstChildWithTag:kUserName] stringValue] copy];
    _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
    _company = [[[xml firstChildWithTag:kCompany] stringValue] copy];
    _job = [[[xml firstChildWithTag:kJob] stringValue] copy];
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _userID == ((OSCEventPersonInfo *)object).userID;
    }
    
    return NO;
}


@end
