//
//  TeamUser.m
//  iosapp
//
//  Created by ChanAetern on 4/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamUser.h"

@implementation TeamUser

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        ONOXMLElement *member = [xml firstChildWithTag:@"member"];
        
        _userID = [[[member firstChildWithTag:@"uid"] numberValue] intValue];
        _name   = [[member firstChildWithTag:@"name"] stringValue];
        _oscName = [[member firstChildWithTag:@"oscName"] stringValue];
        _portraitURL = [NSURL URLWithString:[[member firstChildWithTag:@"portrait"] stringValue]];
        _gender = [[member firstChildWithTag:@"gender"] stringValue];
        _email = [[member firstChildWithTag:@"teamEmail"] stringValue];
        _telephone = [[member firstChildWithTag:@"teamTelephone"] stringValue];
        _job = [[member firstChildWithTag:@"teamJob"] stringValue];
        _role = [[[member firstChildWithTag:@"teamRole"] numberValue] intValue];
        _space = [NSURL URLWithString:[[member firstChildWithTag:@"space"] stringValue]];
        _joinTime = [NSDate dateFromString:[member firstChildWithTag:@"joinTime"].stringValue];
        _location = [[member firstChildWithTag:@"location"] stringValue];
        
        _openedTaskCount = [[[xml firstChildWithTag:@"opened"] numberValue] intValue];
        _underwayTaskCount = [[[xml firstChildWithTag:@"underway"] numberValue] intValue];
        _closedTaskCount = [[[xml firstChildWithTag:@"closed"] numberValue] intValue];
        _acceptedTaskCount = [[[xml firstChildWithTag:@"accepted"] numberValue] intValue];
        _outdateTaskCount = [[[xml firstChildWithTag:@"outdate"] numberValue] intValue];
        _finishedTaskCount = [[[xml firstChildWithTag:@"finished"] numberValue] intValue];
    }
    
    return self;
}

@end
