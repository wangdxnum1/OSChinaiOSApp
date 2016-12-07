//
//  TeamMember.m
//  iosapp
//
//  Created by ChanAetern on 4/15/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamMember.h"

@implementation TeamMember

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _memberID    = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _name        = [[xml firstChildWithTag:@"name"] stringValue];
        _oscName     = [[xml firstChildWithTag:@"oscName"] stringValue];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:@"portrait"] stringValue]];
        _gender      = [[xml firstChildWithTag:@"gender"] stringValue];
        _email       = [[xml firstChildWithTag:@"teamEmail"] stringValue];
        _telephone   = [[xml firstChildWithTag:@"teamTelephone"] stringValue];
        _teamJob     = [[xml firstChildWithTag:@"teamJob"] stringValue];
        _teamRole    = [[[xml firstChildWithTag:@"teamRole"] numberValue] intValue];
        _space       = [NSURL URLWithString:[[xml firstChildWithTag:@"space"] stringValue]];
        _joinTime    = [NSDate dateFromString:[xml firstChildWithTag:@"joinTime"].stringValue];
        _location    = [[xml firstChildWithTag:@"location"] stringValue];
    }
    
    return self;
}

- (instancetype)initWithCollaboratorXML:(ONOXMLElement *)xml
{
//    <collaborator>
//    <id>3229</id>
//    <user>2351247</user>
//    <name><![CDATA[Ho1den]]></name>
//    <portrait>http://static.oschina.net/uploads/user/1175/2351247_100.png?t=1429676731000</portrait>
//				</collaborator>

    if (self = [super init]) {
        _memberID    = [[[xml firstChildWithTag:@"user"] numberValue] intValue];
        _name        = [[xml firstChildWithTag:@"name"] stringValue];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:@"portrait"] stringValue]];
    }
    return self;
}
@end
