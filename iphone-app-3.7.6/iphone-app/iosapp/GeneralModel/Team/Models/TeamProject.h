//
//  TeamProject.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamProject : OSCBaseObject

@property (nonatomic, assign) int projectID;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, assign) int teamID;

@property (nonatomic, assign) int gitID;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *projectPath;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *ownerUserName;

@property (nonatomic, assign) int openedIssueCount;
@property (nonatomic, assign) int allIssueCount;
@property (nonatomic, assign) BOOL gitPush;

@property (nonatomic, strong) NSMutableAttributedString *attributedTitle;


@end
