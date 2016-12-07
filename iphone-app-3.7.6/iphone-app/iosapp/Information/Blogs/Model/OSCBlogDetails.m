//
//  OSCBlogDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCBlogDetails.h"
#import "Utils.h"


@implementation OSCBlogDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        _blogID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:@"url"] stringValue]];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _commentCount = [[[xml firstChildWithTag:@"commentCount"] numberValue] intValue];
        _author = [[xml firstChildWithTag:@"author"] stringValue];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:@"pubDate"].stringValue];
        _isFavorite = [[[xml firstChildWithTag:@"favorite"] numberValue] boolValue];
        _where = [[xml firstChildWithTag:@"where"] stringValue];
        _documentType = [[[xml firstChildWithTag:@"documentType"] numberValue] intValue];
    }
    
    return self;
}

- (instancetype)initWithTBXMLElement:(TBXMLElement*)element {
    self = [super init];
    
    if (self) {
        _blogID = [[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:element]] longLongValue];
        _title = [TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:element]] ;
        _url = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"url" parentElement:element]]];
        _body = [TBXML textForElement:[TBXML childElementNamed:@"body" parentElement:element]];
        _commentCount = [[TBXML textForElement:[TBXML childElementNamed:@"commentCount" parentElement:element]] intValue];
        _author = [TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:element]];
        _authorID = [[TBXML textForElement:[TBXML childElementNamed:@"authorid" parentElement:element]] longLongValue];
        _pubDate = [NSDate dateFromString:[TBXML textForElement:[TBXML childElementNamed:@"pubDate" parentElement:element]]];
        _isFavorite = [[TBXML textForElement:[TBXML childElementNamed:@"favorite" parentElement:element]] boolValue];
        _where = [TBXML textForElement:[TBXML childElementNamed:@"where" parentElement:element]];
        _documentType = [[TBXML textForElement:[TBXML childElementNamed:@"documentType" parentElement:element]] intValue];
    }
    
    return self;
}


- (NSString *)html
{
    if (!_html) {
        NSDictionary *data = @{
                               @"title": [_title escapeHTML],
                               @"authorID": @(_authorID),
                               @"authorName": _author,
                               @"timeInterval": [_pubDate timeAgoSinceNow],
                               @"content": _body,
                               };
        
        _html = [Utils HTMLWithData:data usingTemplate:@"article"];
    }
    
    return _html;
}

@end
