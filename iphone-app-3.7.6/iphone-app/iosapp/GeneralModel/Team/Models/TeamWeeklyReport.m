//
//  TeamWeeklyReport.m
//  iosapp
//
//  Created by AeternChan on 4/29/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamWeeklyReport.h"
#import <UIKit/UIKit.h>

@implementation TeamWeeklyReport

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _reportID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _replyCount = [[[xml firstChildWithTag:@"reply"] numberValue] intValue];
        _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        
        ONOXMLElement *authorXML = [xml firstChildWithTag:@"author"];
        _author = [[TeamMember alloc] initWithXML:authorXML];
    }
    
    return self;
}

- (NSMutableAttributedString *)attributedTitle
{
    if (!_attributedTitle) {
        _attributedTitle = [[NSMutableAttributedString alloc] initWithData:[_title dataUsingEncoding:NSUnicodeStringEncoding]
                                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                         documentAttributes:nil
                                                                      error:nil];
        
        [_attributedTitle deleteCharactersInRange:NSMakeRange(_attributedTitle.length-1, 1)];
        
        [_attributedTitle addAttributes:@{
                                          NSFontAttributeName:[UIFont systemFontOfSize:14],
                                          NSForegroundColorAttributeName:[UIColor grayColor]
                                          }
                                   range:NSMakeRange(0, _attributedTitle.length)];
    }
    
    return _attributedTitle;
}

@end
