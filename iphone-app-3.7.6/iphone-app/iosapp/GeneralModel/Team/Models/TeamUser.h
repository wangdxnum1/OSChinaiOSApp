//
//  TeamUser.h
//  iosapp
//
//  Created by ChanAetern on 4/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamUser : OSCBaseObject

@property (nonatomic, assign) int userID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *oscName;
@property (nonatomic, strong) NSURL *portraitURL;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *job;
@property (nonatomic, assign) int role;
@property (nonatomic, strong) NSURL *space;
@property (nonatomic, strong) NSDate *joinTime;
@property (nonatomic, copy) NSString *location;

@property (nonatomic, assign) int openedTaskCount;
@property (nonatomic, assign) int underwayTaskCount;
@property (nonatomic, assign) int closedTaskCount;
@property (nonatomic, assign) int acceptedTaskCount;
@property (nonatomic, assign) int outdateTaskCount;
@property (nonatomic, assign) int finishedTaskCount;
@property (nonatomic, assign) int allTaskCount;

@end
