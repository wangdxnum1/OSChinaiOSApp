//
//  TeamTeam.h
//  iosapp
//
//  Created by AeternChan on 4/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamTeam : OSCBaseObject

@property (nonatomic, assign) int teamID;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int status;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *ident;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *qqNumber;

@end
