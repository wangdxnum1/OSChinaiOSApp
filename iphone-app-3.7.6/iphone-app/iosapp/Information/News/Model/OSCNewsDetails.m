//
//  OSCNewsDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 10/31/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCNewsDetails.h"
#import "Utils.h"


@implementation OSCNewsDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        _newsID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:@"url"] stringValue]];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _commentCount = [[[xml firstChildWithTag:@"commentCount"] numberValue] intValue];
        _author = [[xml firstChildWithTag:@"author"] stringValue];
        _authorID = [[[xml firstChildWithTag:@"authorid"] numberValue] longLongValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:@"pubDate"].stringValue];
        _softwareLink = [NSURL URLWithString:[[xml firstChildWithTag:@"softwarelink"] stringValue]];
        _softwareName = [[xml firstChildWithTag:@"softwarename"] stringValue];
        _isFavorite = [[[xml firstChildWithTag:@"favorite"] numberValue] boolValue];
        NSMutableArray *mutableRelatives = [NSMutableArray new];
        NSArray *relativesXML = [[xml firstChildWithTag:@"relativies"] childrenWithTag:@"relative"];
        for (ONOXMLElement *relativeXML in relativesXML) {
            NSString *rTitle = [[relativeXML firstChildWithTag:@"rtitle"] stringValue];
            NSString *rURL = [[relativeXML firstChildWithTag:@"rurl"] stringValue];
            [mutableRelatives addObject:@[rTitle, rURL]];
        }
        _relatives = [NSArray arrayWithArray:mutableRelatives];
    }
    
    return self;
}

- (instancetype)initWithTBXMLElement:(TBXMLElement*)element {
    self = [super init];
    
    if (self) {
        _newsID = [[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:element]] longLongValue];
        _title = [TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:element]];
        _url = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"url" parentElement:element]]];
        _body = [TBXML textForElement:[TBXML childElementNamed:@"body" parentElement:element]];
        _commentCount = [[TBXML textForElement:[TBXML childElementNamed:@"commentCount" parentElement:element]] intValue];
        _author = [TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:element]];
        _authorID = [[TBXML textForElement:[TBXML childElementNamed:@"authorid" parentElement:element]] integerValue];
        _pubDate = [NSDate dateFromString:[TBXML textForElement:[TBXML childElementNamed:@"pubDate" parentElement:element]]];
        _softwareLink = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"softwarelink" parentElement:element]]];
        _softwareName = [TBXML textForElement:[TBXML childElementNamed:@"softwarename" parentElement:element]];
        _isFavorite = [[TBXML textForElement:[TBXML childElementNamed:@"favorite" parentElement:element]] boolValue];

        NSMutableArray *mutableRelatives = [NSMutableArray new];
        TBXMLElement *relativies = [TBXML childElementNamed:@"relativies" parentElement:element];
        TBXMLElement *relative = [TBXML childElementNamed:@"relative" parentElement:relativies];
        while (relative) {
            NSString *rTitle = [TBXML textForElement:[TBXML childElementNamed:@"rtitle" parentElement:relative]];
            NSString *rURL = [TBXML textForElement:[TBXML childElementNamed:@"rurl" parentElement:relative]];
            [mutableRelatives addObject:@[rTitle, rURL]];
            relative = [TBXML nextSiblingNamed:@"relative" searchFromElement:relative];
        }
        _relatives = [NSArray arrayWithArray:mutableRelatives];
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
                               @"softwareLink": _softwareLink,
                               @"softwareName": _softwareName,
                               @"relatedInfo": [Utils generateRelativeNewsString:_relatives],
                               };
        
        _html = [Utils HTMLWithData:data usingTemplate:@"article"];
    }
    
    return _html;
}

@end
