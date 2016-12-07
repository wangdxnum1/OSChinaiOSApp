//
//  OSCUser.m
//  iosapp
//
//  Created by chenhaoxiang on 11/5/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCUser.h"

@implementation OSCUser

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (!self) {return nil;}
    // 有些API返回用<id>，有些地方用<userid>，这样写是为了简化处理
    _userID = [[[xml firstChildWithTag:@"uid"] numberValue] longLongValue] | [[[xml firstChildWithTag:@"userid"] numberValue] longLongValue];
    
    // 理由同上
    _location = [[[xml firstChildWithTag:@"location"] stringValue] copy];
    if (!_location) {_location = [[[xml firstChildWithTag:@"from"] stringValue] copy];}
    
    _name = [[[xml firstChildWithTag:@"name"] stringValue] copy];
    _followersCount = [[[xml firstChildWithTag:@"followers"] numberValue] intValue];
    _fansCount = [[[xml firstChildWithTag:@"fans"] numberValue] intValue];
    _score = [[[xml firstChildWithTag:@"score"] numberValue] intValue];
    _relationship = [[[xml firstChildWithTag:@"relation"] numberValue] intValue];
    _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:@"portrait"] stringValue]];
    _favoriteCount = [[[xml firstChildWithTag:@"favoritecount"] numberValue] intValue];
    
    _gender             = [[[xml firstChildWithTag:@"gender"] stringValue] copy];
    
    _developPlatform    = [[[xml firstChildWithTag:@"devplatform"] stringValue] copy];
    _expertise = [[[xml firstChildWithTag:@"expertise"] stringValue] copy];
    _joinTime = [NSDate dateFromString:[xml firstChildWithTag:@"jointime"].stringValue];
    _latestOnlineTime = [NSDate dateFromString:[xml firstChildWithTag:@"latestonline"].stringValue];
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _userID == ((OSCUser *)object).userID;
    }
    
    return NO;
}


@end
