//
//  TeamDiscussion.m
//  iosapp
//
//  Created by AeternChan on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamDiscussion.h"

@implementation TeamDiscussion

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _discussionID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        _answerCount = [[[xml firstChildWithTag:@"answerCount"] numberValue] intValue];
        _voteUpCount = [[[xml firstChildWithTag:@"voteUp"] numberValue] intValue];
        _author = [[TeamMember alloc] initWithXML:[xml firstChildWithTag:@"author"]];
    }
    
    return self;
}

@end
