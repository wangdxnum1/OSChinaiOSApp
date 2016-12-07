//
//  OSCPostDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCPostDetails.h"
#import "Utils.h"


@implementation OSCPostDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        _postID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:@"url"] stringValue]];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:@"portrait"] stringValue]];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _author = [[xml firstChildWithTag:@"author"] stringValue];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _answerCount = [[[xml firstChildWithTag:@"answerCount"] numberValue] intValue];
        _viewCount = [[[xml firstChildWithTag:@"viewCount"] numberValue] intValue];
        _isFavorite = [[[xml firstChildWithTag:@"favorite"] numberValue] boolValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:@"pubDate"].stringValue];
        
        ONOXMLElement *eventElement = [xml firstChildWithTag:@"event"];
        _status = [[[eventElement firstChildWithTag:@"status"] numberValue] intValue];
        _applyStatus = [[[eventElement firstChildWithTag:@"applyStatus"] numberValue] intValue];
        _category    = [[[eventElement firstChildWithTag:@"category"] numberValue] intValue];
        _signUpUrl = [NSURL URLWithString:[[eventElement firstChildWithTag:@"url"] stringValue]];
        
        NSMutableArray *mutableTags = [NSMutableArray new];
        NSArray *tagsXML = [xml childrenWithTag:@"tags"];
        for (ONOXMLElement *tagXML in tagsXML) {
            NSString *tag = [[tagXML firstChildWithTag:@"tag"] stringValue];
            [mutableTags addObject:tag];
        }
        _tags = [NSArray arrayWithArray:mutableTags];
    }
    
    return self;
}

- (instancetype)initWithTBXMLElement:(TBXMLElement*)element {
    self = [super init];
    
    if (self) {
        _postID = [[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:element]] longLongValue];
        _title = [TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:element]];
        _url = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"url" parentElement:element]]];
        _portraitURL = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"portrait" parentElement:element]]];
        _body = [TBXML textForElement:[TBXML childElementNamed:@"body" parentElement:element]];
        _author = [TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:element]];
        _authorID = [[TBXML textForElement:[TBXML childElementNamed:@"authorid" parentElement:element]] integerValue];
        _answerCount = [[TBXML textForElement:[TBXML childElementNamed:@"answerCount" parentElement:element]] intValue];
        _viewCount = [[TBXML textForElement:[TBXML childElementNamed:@"viewCount" parentElement:element]] intValue];
        _isFavorite = [[TBXML textForElement:[TBXML childElementNamed:@"favorite" parentElement:element]] boolValue];
        _pubDate = [NSDate dateFromString:[TBXML textForElement:[TBXML childElementNamed:@"pubDate" parentElement:element]]];

        TBXMLElement *eventElement = [TBXML childElementNamed:@"event" parentElement:element];
        if (eventElement && eventElement->firstChild) {
            _status = [[TBXML textForElement:[TBXML childElementNamed:@"status" parentElement:eventElement]] intValue];
            _applyStatus = [[TBXML textForElement:[TBXML childElementNamed:@"applyStatus" parentElement:eventElement]] intValue];
            _category    = [[TBXML textForElement:[TBXML childElementNamed:@"category" parentElement:eventElement]] intValue];
            _signUpUrl = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"url" parentElement:eventElement]]];
        }
        
        TBXMLElement *tags = [TBXML childElementNamed:@"tags" parentElement:element];
        if (tags) {
            NSMutableArray *mutableTags = [NSMutableArray new];
            TBXMLElement *tag = [TBXML childElementNamed:@"tag" parentElement:tags];
            while (tag) {
                NSString *tagStr = [TBXML textForElement:tag];
                [mutableTags addObject:tagStr];
                tag = [TBXML nextSiblingNamed:@"tag" searchFromElement:tag];
            }
            _tags = [NSArray arrayWithArray:mutableTags];
        }
        
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
                               @"tags": [Utils generateTags:_tags],
                               };
        
        _html = [Utils HTMLWithData:data usingTemplate:@"article"];
    }
    
    return _html;
}

@end
