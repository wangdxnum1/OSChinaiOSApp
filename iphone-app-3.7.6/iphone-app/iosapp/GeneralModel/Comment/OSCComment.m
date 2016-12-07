//
//  OSCComment.m
//  iosapp
//
//  Created by chenhaoxiang on 10/28/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCComment.h"
#import "Utils.h"



static NSString * const kID = @"id";
static NSString * const kPortrait = @"portrait";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kContent = @"content";
static NSString * const kPubDate = @"pubDate";
static NSString * const kAppclient = @"appclient";
static NSString * const kReplies = @"replies";
static NSString * const kReply = @"reply";
static NSString * const kRefers = @"refers";
static NSString * const kRefer = @"refer";
static NSString * const kRauthor = @"rauthor";
static NSString * const kRContent = @"rcontent";

@implementation OSCComment

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _commentID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        _content = [[xml firstChildWithTag:kContent] stringValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:kPubDate].stringValue];
        _appclient = [[[xml firstChildWithTag:kAppclient] numberValue] intValue];
        
        NSMutableArray *mutableReplies = [NSMutableArray new];
        NSArray *repliesXML = [[xml firstChildWithTag:kReplies] childrenWithTag:kReply];
        for (ONOXMLElement *replyXML in repliesXML) {
            OSCReply *reply = [[OSCReply alloc] initWithXML:replyXML];
            [mutableReplies addObject:reply];
        }
        _replies = [NSArray arrayWithArray:mutableReplies];
        
        NSMutableArray *mutableReferences = [NSMutableArray new];
        NSArray *refersXML = [[xml firstChildWithTag:kRefers] childrenWithTag:kRefer];
        for (ONOXMLElement *referXML in refersXML) {
            OSCReference *reference = [[OSCReference alloc] initWithXML:referXML];
            [mutableReferences addObject:reference];
        }
        _references = [NSArray arrayWithArray:mutableReferences];
    }
    
    return self;
}

- (instancetype)initWithReplyXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _commentID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];

        
        _teamMember = [[TeamMember alloc]initWithXML:[xml firstChildWithTag:kAuthor]];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:@"createTime"].stringValue];
        _content = [[xml firstChildWithTag:kContent] stringValue];
        
    }
    
    return self;
}


+ (NSAttributedString *)attributedTextFromReplies:(NSArray *)replies
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n--共有%lu条评论--\n", (unsigned long)replies.count]
                                                                                       attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    
    [replies enumerateObjectsUsingBlock:^(OSCReply *reply, NSUInteger idx, BOOL *stop) {
        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：", reply.author]
                                                                                          attributes:@{
                                                                                                       NSForegroundColorAttributeName:[UIColor nameColor],
                                                                                                       NSFontAttributeName:[UIFont systemFontOfSize:13]
                                                                                                       }];
        NSMutableAttributedString *replyContent = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:reply.content]];
        [replyContent addAttributes:@{
                                      NSForegroundColorAttributeName:[UIColor grayColor],
                                      NSFontAttributeName:[UIFont systemFontOfSize:13]
                                      } range:NSMakeRange(0, replyContent.length)];
        [commentString appendAttributedString:replyContent];
        
        [attributedText appendAttributedString:commentString];
        
        if (idx != replies.count-1) {
            [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        } else {
            *stop = YES;
        }
    }];
    
    return [attributedText copy];
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _commentID == ((OSCComment *)object).commentID;
    }
    
    return NO;
}

@end
