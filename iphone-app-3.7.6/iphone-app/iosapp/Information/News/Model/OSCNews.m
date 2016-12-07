//
//  OSCNews.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OSCNews.h"
#import "Utils.h"

#import <DateTools.h>

static NSString * const kID = @"id";
static NSString * const kTitle = @"title";
static NSString * const kBody = @"body";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kPubDate = @"pubDate";
static NSString * const kNewsType = @"newstype";
static NSString * const kType = @"type";
static NSString * const kAttachment = @"attachment";
static NSString * const kAuthorUID2 = @"authoruid2";

@implementation OSCNews

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _newsID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _body = [[xml firstChildWithTag:kBody] stringValue];
        
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:kPubDate].stringValue];
        
        _url = [NSURL URLWithString:[[[xml firstChildWithTag:@"url"] stringValue]
                                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        ONOXMLElement *newsType = [xml firstChildWithTag:kNewsType];
        _type = [[[newsType firstChildWithTag:kType] numberValue] intValue];
        _attachment = [[newsType firstChildWithTag:kAttachment] stringValue];
        _authorUID2 = [[[newsType firstChildWithTag:kAuthorUID2] numberValue] longLongValue];
        _eventURL = [NSURL URLWithString:[[[newsType firstChildWithTag:@"eventurl"] stringValue]
                                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    return self;
}

- (NSAttributedString *)attributedTittle
{
    if (!_attributedTittle) {
        if ([_pubDate isToday]) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"widget_taday"];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            _attributedTittle = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            [_attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [_attributedTittle appendAttributedString:[[NSAttributedString alloc] initWithString:_title]];
        } else {
            _attributedTittle = [[NSMutableAttributedString alloc] initWithString:_title];
        }
        
    }
    
    return _attributedTittle;
}

- (NSAttributedString *)attributedCommentCount
{
    if (!_attributedCommentCount) {
        _attributedCommentCount = [Utils attributedCommentCount:_commentCount];
    }
    
    return _attributedCommentCount;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _newsID == ((OSCNews *)object).newsID;
    }
    
    return NO;
}


@end


