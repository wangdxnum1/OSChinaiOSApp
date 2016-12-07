//
//  OSCSearchResult.h
//  iosapp
//
//  Created by ChanAetern on 1/22/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCSearchResult : OSCBaseObject

@property (nonatomic, readonly, assign) int64_t objectID;
@property (nonatomic, readonly, copy) NSString *type;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *author;
@property (nonatomic, readonly, copy) NSString *objectDescription;
@property (nonatomic, readonly, strong) NSURL *url;
@property (nonatomic, readonly, strong) NSDate *pubDate;

@end
