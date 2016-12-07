//
//  OSCPost.m
//  iosapp
//
//  Created by chenhaoxiang on 10/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCPost.h"

static NSString * const kID = @"id";
static NSString * const kPortrait = @"portrait";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kTitle = @"title";
static NSString * const kBody = @"body";
static NSString * const kReplyCount = @"answerCount";
static NSString * const kViewCount = @"viewCount";
static NSString * const kPubDate = @"pubDate";

@implementation OSCPost

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    self = [super init];
    if (self) {
        _postID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _title = [[xml firstChildWithTag:kTitle] stringValue];
        _body = [[xml firstChildWithTag:kBody] stringValue];
        _replyCount = [[[xml firstChildWithTag:kReplyCount] numberValue] intValue];
        _viewCount = [[[xml firstChildWithTag:kViewCount] numberValue] intValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:kPubDate].stringValue];
    }

    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _postID == ((OSCPost *)object).postID;
    }
    
    return NO;
}

@end
