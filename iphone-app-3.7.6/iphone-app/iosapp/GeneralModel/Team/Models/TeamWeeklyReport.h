//
//  TeamWeeklyReport.h
//  iosapp
//
//  Created by AeternChan on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import "TeamMember.h"

@interface TeamWeeklyReport : OSCBaseObject

@property (nonatomic, assign) int reportID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int replyCount;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) TeamMember *author;
@property (nonatomic, strong) NSMutableAttributedString *attributedTitle;

@end
