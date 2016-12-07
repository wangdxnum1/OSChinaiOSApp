//
//  OSCSoftware.h
//  iosapp
//
//  Created by chenhaoxiang on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCSoftware : OSCBaseObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *softwareDescription;
@property (nonatomic, copy) NSURL *url;

//v2接口
@property (nonatomic)NSInteger softId;
@end
