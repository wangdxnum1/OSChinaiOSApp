//
//  TeamReply.m
//  iosapp
//
//  Created by AeternChan on 5/8/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamReply.h"
#import "Utils.h"
@implementation TeamReply

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _replyID = [[[xml firstChildWithTag:@"id"] numberValue] intValue];
        _type = [[[xml firstChildWithTag:@"type"] numberValue] intValue];
        _appclient = [[[xml firstChildWithTag:@"appclient"] numberValue] intValue];
        _appName = [[xml firstChildWithTag:@"appName"] stringValue];
        NSString *rawString = [[xml firstChildWithTag:@"content"].stringValue deleteHTMLTag];
        _content = [Utils emojiStringFromRawString:rawString];
        _createTime = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        
        ONOXMLElement *authorXML = [xml firstChildWithTag:@"author"];
        _author = [[TeamMember alloc] initWithXML:authorXML];
    }
    
    return self;
}


- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _replyID == ((TeamReply *)object).replyID;
    }
    
    return NO;
}


//- (NSAttributedString *)attributedContent
//{
//    if (!_attributedContent) {
//        _attributedContent = [[NSMutableAttributedString alloc] initWithData:[_content dataUsingEncoding:NSUnicodeStringEncoding]
//                                                                   options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
//                                                        documentAttributes:nil
//                                                                     error:nil];
//        
//        [_attributedContent deleteCharactersInRange:NSMakeRange(_attributedContent.length-1, 1)];
//        
//        [_attributedContent addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
//                                  range:NSMakeRange(0, _attributedContent.length)];
//    }
//    
//    return _attributedContent;
//}


@end
