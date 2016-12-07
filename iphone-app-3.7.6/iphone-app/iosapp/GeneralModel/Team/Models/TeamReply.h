//
//  TeamReply.h
//  iosapp
//
//  Created by AeternChan on 5/8/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import "TeamMember.h"

@interface TeamReply : OSCBaseObject

@property (nonatomic, assign) int replyID;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int appclient;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSAttributedString *content;
@property (nonatomic, strong) NSDate *createTime;

@property (nonatomic, strong) TeamMember *author;
//@property (nonatomic, strong) NSMutableAttributedString *attributedContent;

@end
