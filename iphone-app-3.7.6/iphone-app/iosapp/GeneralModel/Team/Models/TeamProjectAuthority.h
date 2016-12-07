//
//  TeamProjectAuthority.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamProjectAuthority : OSCBaseObject

@property (nonatomic, assign) BOOL authDelete;
@property (nonatomic, assign) BOOL authUpdateState;
@property (nonatomic, assign) BOOL authUpdateAssignee;
@property (nonatomic, assign) BOOL authUpdateDeadline;
@property (nonatomic, assign) BOOL authUpdatePriority;
@property (nonatomic, assign) BOOL authUpdateLabels;

@end
