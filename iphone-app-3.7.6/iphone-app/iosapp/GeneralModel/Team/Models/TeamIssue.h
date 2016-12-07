//
//  TeamIssue.h
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

#import "TeamProject.h"
#import "TeamProjectAuthority.h"
#import "TeamMember.h"

@interface TeamIssue : OSCBaseObject

@property (nonatomic, assign) int issueID;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, assign) int stateLevel;
@property (nonatomic, copy) NSString *priority;
@property (nonatomic, assign) BOOL gitPush;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, assign) int catalogID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *issueDescription;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *updateTime;
@property (nonatomic, strong) NSDate *acceptTime;
@property (nonatomic, strong) NSDate *deadline;
@property (nonatomic, assign) int replyCount;
@property (nonatomic, strong) NSURL *gitIssueURL;
@property (nonatomic, strong) TeamMember *author;
@property (nonatomic, strong) TeamMember *user;
@property (nonatomic, strong) TeamProjectAuthority *authority;


@property (nonatomic, strong) TeamProject *project;
@property (nonatomic, assign) int childIssuesCount;
@property (nonatomic, assign) int closedChildIssuesCount;
@property (nonatomic, assign) int attachmentsCount;
@property (nonatomic, assign) int relatedIssuesCount;

@property (nonatomic, assign) BOOL hasExtraInfo;


@property (nonatomic,strong) NSMutableArray *childIssues;       //任务详情的子任务
@property (nonatomic,strong) NSMutableArray *issueLabels;       //任务标签
@property (nonatomic,strong) NSMutableArray *collaborators;     //协助者


@property (nonatomic, strong) NSMutableAttributedString *attributedIssueTitle;


- (instancetype)initWithDetailIssueXML:(ONOXMLElement *)xml;


@end
