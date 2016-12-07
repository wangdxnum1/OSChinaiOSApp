//
//  OSCReference.h
//  iosapp
//
//  Created by ChanAetern on 2/27/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCReference : OSCBaseObject <NSCopying>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *body;

@end
