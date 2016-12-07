//
//  OSCEventPersonInfo.h
//  iosapp
//
//  Created by 李萍 on 15/3/6.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface OSCEventPersonInfo : OSCBaseObject

@property (nonatomic, readonly, copy) NSString *userName;
@property (nonatomic, readonly, assign) int64_t userID;
@property (nonatomic, readonly, strong) NSURL *portraitURL;
@property (nonatomic, readonly, copy) NSString *company;
@property (nonatomic, readonly, copy) NSString *job;

@end
