//
//  TeamDiscussion.h
//  iosapp
//
//  Created by AeternChan on 4/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import "TeamMember.h"

@interface TeamDiscussion : OSCBaseObject

@property (nonatomic, assign) int discussionID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, assign) int answerCount;
@property (nonatomic, assign) int voteUpCount;
@property (nonatomic, strong) TeamMember *author;

@end
