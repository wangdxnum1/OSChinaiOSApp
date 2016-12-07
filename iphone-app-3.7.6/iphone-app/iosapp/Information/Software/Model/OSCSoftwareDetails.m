//
//  OSCSoftwareDetails.m
//  iosapp
//
//  Created by chenhaoxiang on 11/3/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCSoftwareDetails.h"
#import "Utils.h"


@implementation OSCSoftwareDetails

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    
    if (self) {
        _authorID = [xml firstChildWithTag:@"authorid"].numberValue.integerValue;
        _author = [xml firstChildWithTag:@"author"].stringValue ?: @"";
        _softwareID = [[[xml firstChildWithTag:@"id"] numberValue] longLongValue];
        _isRecommended = [xml firstChildWithTag:@"recommended"].numberValue.boolValue;
        _title = [[xml firstChildWithTag:@"title"] stringValue];
        _extensionTitle = [[xml firstChildWithTag:@"extensionTitle"] stringValue];
        _license = [[xml firstChildWithTag:@"license"] stringValue];
        _body = [[xml firstChildWithTag:@"body"] stringValue];
        _os = [[xml firstChildWithTag:@"os"] stringValue];
        _language = [[xml firstChildWithTag:@"language"] stringValue];
        _recordTime = [[xml firstChildWithTag:@"recordtime"] stringValue];
        _url = [NSURL URLWithString:[[xml firstChildWithTag:@"url"] stringValue]];
        _homepageURL = [[xml firstChildWithTag:@"homepage"] stringValue];
        _documentURL = [[xml firstChildWithTag:@"document"] stringValue];
        _downloadURL = [[xml firstChildWithTag:@"download"] stringValue];
        _logoURL = [[xml firstChildWithTag:@"logo"] stringValue];
        _isFavorite = [[[xml firstChildWithTag:@"favorite"] numberValue] boolValue];
        _tweetCount = [[[xml firstChildWithTag:@"tweetCount"] numberValue] intValue];
    }
    
    return self;
}

- (instancetype)initWithTBXMLElement:(TBXMLElement*)element {
    self = [super init];
    
    if (self) {
        _authorID = [[TBXML textForElement:[TBXML childElementNamed:@"authorid" parentElement:element]] integerValue];
        _author = [TBXML textForElement:[TBXML childElementNamed:@"author" parentElement:element]];
        _title = [TBXML textForElement:[TBXML childElementNamed:@"title" parentElement:element]];
        _softwareID = [[TBXML textForElement:[TBXML childElementNamed:@"id" parentElement:element]] longLongValue];
        _isRecommended = [[TBXML textForElement:[TBXML childElementNamed:@"recommended" parentElement:element]] boolValue];
        _url = [NSURL URLWithString:[TBXML textForElement:[TBXML childElementNamed:@"url" parentElement:element]]];
        _body = [TBXML textForElement:[TBXML childElementNamed:@"body" parentElement:element]];
        _extensionTitle = [TBXML textForElement:[TBXML childElementNamed:@"extensionTitle" parentElement:element]];
        _license = [TBXML textForElement:[TBXML childElementNamed:@"license" parentElement:element]];
        _os = [TBXML textForElement:[TBXML childElementNamed:@"os" parentElement:element]];
        _language = [TBXML textForElement:[TBXML childElementNamed:@"language" parentElement:element]];
        _recordTime = [TBXML textForElement:[TBXML childElementNamed:@"recordtime" parentElement:element]];
        _homepageURL = [TBXML textForElement:[TBXML childElementNamed:@"homepage" parentElement:element]];
        _documentURL = [TBXML textForElement:[TBXML childElementNamed:@"document" parentElement:element]];
        _downloadURL = [TBXML textForElement:[TBXML childElementNamed:@"download" parentElement:element]];
        _logoURL = [TBXML textForElement:[TBXML childElementNamed:@"logo" parentElement:element]];
        _isFavorite = [[TBXML textForElement:[TBXML childElementNamed:@"favorite" parentElement:element]] boolValue];
        _tweetCount = [[TBXML textForElement:[TBXML childElementNamed:@"tweetCount" parentElement:element]] intValue];
    }
    
    return self;
}

- (NSString *)html
{
    if (!_html) {        
        NSDictionary *data = @{
                               @"title": [NSString stringWithFormat:@"%@ %@", _extensionTitle, _title],
                               @"authorID": @(_authorID),
                               @"author": _author,
                               @"recommended": @(_isRecommended),
                               @"logoURL": _logoURL,
                               @"content": _body,
                               @"license": _license,
                               @"language": _language,
                               @"os": _os,
                               @"recordTime": _recordTime,
                               @"homepageURL": _homepageURL,
                               @"documentURL": _documentURL,
                               @"downloadURL": _downloadURL,
                               };
        
        _html = [Utils HTMLWithData:data usingTemplate:@"software"];
    }
    
    return _html;
}

@end
