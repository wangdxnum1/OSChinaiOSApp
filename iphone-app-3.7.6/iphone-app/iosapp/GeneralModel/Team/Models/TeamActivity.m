//
//  TeamActivity.m
//  iosapp
//
//  Created by ChanAetern on 4/17/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamActivity.h"
#import "TeamMember.h"
#import "Utils.h"

#import <UIKit/UIKit.h>

@implementation TeamActivity

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _activityID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _type = [[[xml firstChildWithTag:@"type"] numberValue] intValue];
        _appID = [[[xml firstChildWithTag:@"appid"] numberValue] intValue];
        _appName = [[xml firstChildWithTag:@"appName"] stringValue];
        _replyCount = [[[xml firstChildWithTag:@"reply"] numberValue] intValue];
        _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        
        ONOXMLElement *bodyXML = [xml firstChildWithTag:@"body"];
        _title = [[bodyXML firstChildWithTag:@"title"] stringValue];
        _detail = [[bodyXML firstChildWithTag:@"detail"] stringValue];
        _code = [[bodyXML firstChildWithTag:@"code"] stringValue];
        _codeType = [[bodyXML firstChildWithTag:@"codeType"] stringValue];
        _imageURL = [NSURL URLWithString:[[bodyXML firstChildWithTag:@"image"] stringValue]];
        _originImageURL = [NSURL URLWithString:[[bodyXML firstChildWithTag:@"imageOrigin"] stringValue]];
        
        ONOXMLElement *authorXML = [xml firstChildWithTag:@"author"];
        _author = [[TeamMember alloc] initWithXML:authorXML];
    }
    
    return self;
}

- (NSAttributedString *)attributedTitle
{
    if (!_attributedTitle) {
        _attributedTitle = [[NSMutableAttributedString alloc] initWithData:[_title dataUsingEncoding:NSUnicodeStringEncoding]
                                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                         documentAttributes:nil
                                                                      error:nil];
        
        if (_attributedTitle.length) {      // 防止单一emoji导致崩溃
            [_attributedTitle deleteCharactersInRange:NSMakeRange(_attributedTitle.length-1, 1)];
            
            [_attributedTitle addAttributes:@{
                                              NSFontAttributeName:[UIFont systemFontOfSize:15],
                                              NSForegroundColorAttributeName: [UIColor titleColor]
                                              }
                                      range:NSMakeRange(0, _attributedTitle.length)];
        }
    }
    
    return _attributedTitle;
}

- (NSAttributedString *)attributedDetail
{
    if (!_attributedDetail) {
        NSMutableAttributedString *attributedDetail = [[NSMutableAttributedString alloc] initWithAttributedString:_attributedTitle];
        
        NSAttributedString *attributedString = [Utils attributedStringFromHTML:_detail];
        if (![attributedString.string isEqualToString:@"\n"]) {
            [attributedDetail appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
            [attributedDetail appendAttributedString:attributedString];
        }
        [attributedDetail addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                          NSForegroundColorAttributeName: [UIColor titleColor]
                                          }
                                  range:NSMakeRange(0, attributedDetail.length)];
        
        _attributedDetail = [[NSAttributedString alloc] initWithAttributedString:attributedDetail];
    }
    
    return _attributedDetail;
}

@end
