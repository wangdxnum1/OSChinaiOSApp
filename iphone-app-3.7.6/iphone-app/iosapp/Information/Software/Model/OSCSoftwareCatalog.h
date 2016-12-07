//
//  OSCSoftwareCatalog.h
//  iosapp
//
//  Created by chenhaoxiang on 12/9/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCSoftwareCatalog : OSCBaseObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) int tag;

@end
