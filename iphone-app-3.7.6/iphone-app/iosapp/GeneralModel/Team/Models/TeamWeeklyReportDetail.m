//
//  TeamWeeklyReportDetail.m
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamWeeklyReportDetail.h"
#import "Utils.h"

#import <UIKit/UIKit.h>

@implementation TeamWeeklyReportDetail

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _reportID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _replyCount = [[[xml firstChildWithTag:@"reply"] numberValue] intValue];
        _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        
        ONOXMLElement *authorXML = [xml firstChildWithTag:@"author"];
        _author = [[TeamMember alloc] initWithXML:authorXML];
        
        NSString *summaryHTML = [[xml firstChildWithTag:@"summary"] stringValue];
        NSMutableAttributedString *attributedSummary = [Utils attributedStringFromHTML:summaryHTML];
        [attributedSummary deleteCharactersInRange:NSMakeRange(attributedSummary.length-1, 1)];
        [attributedSummary addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                           NSForegroundColorAttributeName: [UIColor titleColor]
                                           }
                                   range:NSMakeRange(0, attributedSummary.length)];
        _summary = attributedSummary;
        
        ONOXMLElement *detailsXML = [xml firstChildWithTag:@"detail"];
        NSArray *tags = @[@"sun", @"sat", @"fri", @"thu", @"wed", @"tue", @"mon"];
        NSArray *days = @[@"星期天", @"星期六", @"星期五", @"星期四", @"星期三", @"星期二", @"星期一"];
        NSMutableArray *mutableDetails = [NSMutableArray new];
        [tags enumerateObjectsUsingBlock:^(NSString *tag, NSUInteger idx, BOOL *stop) {
            NSString *HTML = [detailsXML firstChildWithTag:tag].stringValue;
            NSMutableAttributedString *attributedDetail = [Utils attributedStringFromHTML:HTML];
            
            [attributedDetail addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                              NSForegroundColorAttributeName: [UIColor titleColor]
                                              }
                                      range:NSMakeRange(0, attributedDetail.length)];
            
            if (HTML) {
                [mutableDetails addObject:@[days[idx], attributedDetail]];
                _days++;
            }
        }];
        
        _details = [NSArray arrayWithArray:mutableDetails];
    }
    
    return self;
}



@end
