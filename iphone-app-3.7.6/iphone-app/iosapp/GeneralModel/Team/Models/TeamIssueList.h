//
//  TeamIssueList.h
//  iosapp
//
//  Created by Holden on 15/4/28.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCBaseObject.h"

@interface TeamIssueList : OSCBaseObject

@property (nonatomic, assign) int teamIssueID;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *listDescription;
@property (nonatomic, assign) BOOL archive;

@property (nonatomic, assign) int openedIssueCount;
@property (nonatomic, assign) int closedIssueCount;
@property (nonatomic, assign) int allIssueCount;

@end
