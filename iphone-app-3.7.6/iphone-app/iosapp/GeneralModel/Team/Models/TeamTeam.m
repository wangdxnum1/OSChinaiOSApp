//
//  TeamTeam.m
//  iosapp
//
//  Created by AeternChan on 4/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamTeam.h"

@implementation TeamTeam

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _teamID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _type = [[[xml firstChildWithTag:@"type"] numberValue] intValue];
        _status = [[[xml firstChildWithTag:@"status"] numberValue] intValue];
        _name = [[xml firstChildWithTag:@"name"] stringValue];
        _ident = [[xml firstChildWithTag:@"ident"] stringValue];
        _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        
        ONOXMLElement *aboutXML = [xml firstChildWithTag:@"about"];
        _sign = [[aboutXML firstChildWithTag:@"sign"] stringValue];
        _address = [[aboutXML firstChildWithTag:@"address"] stringValue];
        _phoneNumber = [[aboutXML firstChildWithTag:@"telephone"] stringValue];
        _qqNumber = [[aboutXML firstChildWithTag:@"qq"] stringValue];
    }
    
    return self;
}

@end
