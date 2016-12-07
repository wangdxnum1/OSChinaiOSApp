//
//  TeamProject.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamProject.h"
#import <UIKit/UIKit.h>
#import "Utils.h"
#import "NSString+FontAwesome.h"

@implementation TeamProject

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _projectID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _source = [[xml firstChildWithTag:@"source"] stringValue];
        _teamID = [[[xml firstChildWithTag:@"team"] numberValue] intValue];
        
        ONOXMLElement *gitXML = [xml firstChildWithTag:@"git"];
        _gitID = [[[gitXML firstChildWithTag:@"id"] numberValue] intValue];
        _projectName = [[gitXML firstChildWithTag:@"name"] stringValue];
        _projectPath = [[gitXML firstChildWithTag:@"path"] stringValue];
        _ownerName = [[gitXML firstChildWithTag:@"ownerName"] stringValue];
        _ownerUserName = [[gitXML firstChildWithTag:@"ownerUserName"] stringValue];
        
        ONOXMLElement *issueXML = [xml firstChildWithTag:@"issue"];
        _openedIssueCount = [[[issueXML firstChildWithTag:@"opened"] numberValue] intValue];
        _allIssueCount = [[[issueXML firstChildWithTag:@"all"] numberValue] intValue];
        
        _gitPush = [[xml firstChildWithTag:@"gitpush"].stringValue isEqualToString:@"true"];
    }
    
    return self;
}

- (NSAttributedString *)attributedTitle
{
    if (!_attributedTitle) {
        NSString *title = [NSString stringWithFormat:@"%@ / %@", _ownerName, _projectName];
        NSString *iconString;
        
        if ([_source isEqualToString:@"Git@OSC"]) {
            iconString = [NSString fontAwesomeIconStringForEnum:FAgitSquare];
        } else if ([_source isEqualToString:@"GitHub"]) {
            iconString = [NSString fontAwesomeIconStringForEnum:FAGithubSquare];
        } else {
            iconString = [NSString fontAwesomeIconStringForEnum:FAListAlt];
        }
        
        _attributedTitle = [[NSMutableAttributedString alloc] initWithString:iconString
                                                                 attributes:@{
                                                                              NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:16],
                                                                              NSForegroundColorAttributeName: [UIColor grayColor]
                                                                              }];
        
        [_attributedTitle appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", title]]];
    }
    
    return _attributedTitle;
}


@end
