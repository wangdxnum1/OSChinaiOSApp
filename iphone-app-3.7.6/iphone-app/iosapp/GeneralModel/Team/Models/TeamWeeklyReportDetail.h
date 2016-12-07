//
//  TeamWeeklyReportDetail.h
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"
#import "TeamMember.h"

@interface TeamWeeklyReportDetail : OSCBaseObject

@property (nonatomic, assign) int reportID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int replyCount;
@property (nonatomic, strong) NSDate *createTime;

@property (nonatomic, strong) TeamMember *author;
@property (nonatomic, copy) NSAttributedString *summary;
@property (nonatomic, strong) NSArray *details;
@property (nonatomic, assign) int days;

@end
