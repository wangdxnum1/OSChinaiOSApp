//
//  TeamProjectAuthority.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamProjectAuthority.h"

static NSString * const kTRUE = @"true";

@implementation TeamProjectAuthority

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _authDelete = [[xml firstChildWithTag:@"detele"].stringValue isEqualToString:kTRUE];
        _authUpdateState = [[xml firstChildWithTag:@"updateState"].stringValue isEqualToString:kTRUE];
        _authUpdateAssignee = [[xml firstChildWithTag:@"updateAssinee"].stringValue isEqualToString:kTRUE];
        _authUpdateDeadline = [[xml firstChildWithTag:@"updateDeadlineTime"].stringValue isEqualToString:kTRUE];
        _authUpdatePriority = [[xml firstChildWithTag:@"updatePriority"].stringValue isEqualToString:kTRUE];
        _authUpdateLabels = [[xml firstChildWithTag:@"updateLabels"].stringValue isEqualToString:kTRUE];
    }
    
    return self;
}

@end
