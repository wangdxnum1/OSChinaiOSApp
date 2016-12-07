
//
//  TeamIssue.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamIssue.h"
#import "TeamProject.h"
#import "TeamProjectAuthority.h"
#import "TeamMember.h"

#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

@implementation TeamIssue

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        [self setUpPropertiesWithXML:xml];
    }
    
    return self;
}
-(void)setUpPropertiesWithXML:(ONOXMLElement *)xml
{
    _issueID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
    _state = [[xml firstChildWithTag:@"state"] stringValue];
    _stateLevel = [[[xml firstChildWithTag:@"stateLevel"] numberValue] intValue];
    _priority = [[xml firstChildWithTag:@"priority"] stringValue];
    _gitPush = [[[xml firstChildWithTag:@"gitpush"] numberValue] boolValue];
    _source = [[xml firstChildWithTag:@"source"] stringValue];
    _catalogID = [[[xml firstChildWithTag:@"catalogid"] numberValue] intValue];
    _title = [[xml firstChildWithTag:@"title"] stringValue];
    _issueDescription = [[xml firstChildWithTag:@"description"] stringValue];
    _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
    _updateTime = [NSDate dateFromString:[xml firstChildWithTag:@"updateTime"].stringValue];
    _acceptTime = [NSDate dateFromString:[xml firstChildWithTag:@"acceptTime"].stringValue];
    _deadline = [NSDate dateFromString:[xml firstChildWithTag:@"deadlineTime"].stringValue];
    
    _replyCount = [[[xml firstChildWithTag:@"replyCount"] numberValue] intValue];
    _gitIssueURL = [NSURL URLWithString:[[xml firstChildWithTag:@"gitIssueUrl"] stringValue]];
    //_authority = [[TeamProjectAuthority alloc] initWithXML:[xml firstChildWithTag:@"authority"]];
    _project = [[TeamProject alloc] initWithXML:[xml firstChildWithTag:@"project"]];
    
    ONOXMLElement *childIssuesXML = [xml firstChildWithTag:@"childIssues"];
    _childIssuesCount = [[[childIssuesXML firstChildWithTag:@"totalCount"] numberValue] intValue];
    _closedChildIssuesCount = [[[childIssuesXML firstChildWithTag:@"closedCount"] numberValue] intValue];
    
    _attachmentsCount = [[xml firstChildWithTag:@"attachments"] firstChildWithTag:@"totalCount"].numberValue.intValue;
    _relatedIssuesCount = [[xml firstChildWithTag:@"relations"] firstChildWithTag:@"totalCount"].numberValue.intValue;
    
    _hasExtraInfo = _childIssuesCount || _deadline || _attachmentsCount || _relatedIssuesCount;
    
    _author = [[TeamMember alloc] initWithXML:[xml firstChildWithTag:@"author"]];
    _user = [[TeamMember alloc] initWithXML:[xml firstChildWithTag:@"toUser"]];
}

- (instancetype)initWithDetailIssueXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _authority = [[TeamProjectAuthority alloc] initWithXML:[xml firstChildWithTag:@"authority"]];
        //子任务信息
        NSArray *childIssuesXmlArr = [[xml firstChildWithTag:@"childIssues"] childrenWithTag:@"issue"];
        if (childIssuesXmlArr.count > 0) {
            _childIssues = [NSMutableArray new];
            for (ONOXMLElement *xmlObject in childIssuesXmlArr) {
                id obj = [[TeamIssue alloc] initWithXML:xmlObject];
                [_childIssues addObject:obj];
            }
        }
        //标签信息
        NSArray *labelXmlArr = [[xml firstChildWithTag:@"labels"] childrenWithTag:@"label"];
        if (labelXmlArr.count > 0) {
            _issueLabels = [NSMutableArray new];
            for (ONOXMLElement *xmlObject in labelXmlArr) {
                NSString *remarkName = [[xmlObject firstChildWithTag:@"name"] stringValue]?:@"";
                NSString *remarkColor = [[xmlObject firstChildWithTag:@"color"]stringValue]?:@"";
                NSDictionary *remarkDic = @{@"name":remarkName,@"color":remarkColor};
                [_issueLabels addObject:remarkDic];
            }
        }
        //协助者 collaborators
        NSArray *collaboratorXmlArr = [[xml firstChildWithTag:@"collaborators"] childrenWithTag:@"collaborator"];
        if (collaboratorXmlArr.count > 0) {
            _collaborators = [NSMutableArray new];
            for (ONOXMLElement *xmlObject in collaboratorXmlArr) {
                TeamMember *collaborator = [[TeamMember alloc] initWithCollaboratorXML:xmlObject];
                [_collaborators addObject:collaborator];
            }
        }
    }
    
    [self setUpPropertiesWithXML:xml];
    
    return self;
}


- (NSMutableAttributedString *)attributedIssueTitle
{
    if (!_attributedIssueTitle) {
        NSString *stateString;
        NSString *sourceString;
        
        if ([_state isEqualToString:@"opened"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FACircleO];
        } else if ([_state isEqualToString:@"underway"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FADotCircleO];
        } else if ([_state isEqualToString:@"closed"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FACheckCircleO];
        } else if ([_state isEqualToString:@"accepted"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FALock];
        } else if ([_state isEqualToString:@"outdate"]) {
            stateString = [NSString fontAwesomeIconStringForEnum:FATimesCircleO];
        } else {
            stateString = @"";
        }
        
        if ([_source isEqualToString:@"Git@OSC"]) {
            sourceString = [NSString fontAwesomeIconStringForEnum:FAgitSquare];
        } else if ([_source isEqualToString:@"Github"]) {
            sourceString = [NSString fontAwesomeIconStringForEnum:FAGithubSquare];
        } else {
            sourceString = [NSString fontAwesomeIconStringForEnum:FAInfoCircle];
        }
        
        
        _attributedIssueTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", stateString]
                                                                        attributes:@{
                                                                                     NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:16],
                                                                                     NSForegroundColorAttributeName: [UIColor grayColor]
                                                                                     }];
        [_attributedIssueTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", sourceString]
                                                                                       attributes:@{
                                                                                                    NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:16],
                                                                                                    NSForegroundColorAttributeName: [UIColor grayColor]
                                                                                                    }]];
        
        NSDictionary *titleAttributes = @{};
        if ([_state isEqualToString:@"closed"] || [_state isEqualToString:@"accepted"]) {
            titleAttributes = @{
                                NSForegroundColorAttributeName: [UIColor grayColor],
                                NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)
                                };
        }
        
        [_attributedIssueTitle appendAttributedString:[[NSAttributedString alloc] initWithString:_title attributes:titleAttributes]];
    }
    
    return _attributedIssueTitle;
}





@end
