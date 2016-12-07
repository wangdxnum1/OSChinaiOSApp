//
//  TeamActivity.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@class TeamMember;

@interface TeamActivity : OSCBaseObject

@property (nonatomic, assign) int activityID;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int appID;
@property (nonatomic, copy) NSString *appName;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *codeType;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *originImageURL;
@property (nonatomic, assign) int replyCount;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) TeamMember *author;

@property (nonatomic, copy) NSAttributedString *attributedDetail;
@property (nonatomic, strong) NSMutableAttributedString *attributedTitle;

@end
