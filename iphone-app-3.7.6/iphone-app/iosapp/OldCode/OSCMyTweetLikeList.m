//
//  OSCMyTweetLikeList.m
//  iosapp
//
//  Created by 李萍 on 15/4/9.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "OSCMyTweetLikeList.h"
#import "Utils.h"
#import <UIKit/UIKit.h>

static NSString * const kUser = @"user";
static NSString * const kName = @"name";
static NSString * const kUID = @"uid";
static NSString * const kPortrait = @"portrait";

static NSString * const kTweet = @"tweet";
static NSString * const kID = @"id";
static NSString * const kBody = @"body";
static NSString * const kAuthor = @"author";

static NSString * const kDataTime = @"datatime";

@implementation OSCMyTweetLikeList

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        
        ONOXMLElement *userXML = [xml firstChildWithTag:kUser];
        _name = [[userXML firstChildWithTag:kName] stringValue];
        _userID = [[[userXML firstChildWithTag:kUID] numberValue] longLongValue];
        _portraitURL = [NSURL URLWithString:[[userXML firstChildWithTag:kPortrait] stringValue]];
        
        ONOXMLElement *tweetXML = [xml firstChildWithTag:kTweet];
        _tweetId = [[[tweetXML firstChildWithTag:kID] numberValue] longLongValue];
        _body = [[tweetXML firstChildWithTag:kBody] stringValue];
        _author = [[tweetXML firstChildWithTag:kAuthor] stringValue];
        
        _date = [NSDate dateFromString:[xml firstChildWithTag:kDataTime].stringValue];
    }
    
    return self;

}
- (NSMutableAttributedString *)authorAndBody
{
    if (_authorAndBody) {
        return _authorAndBody;
    } else {
        _authorAndBody = [NSMutableAttributedString new];
        [_authorAndBody appendAttributedString:[[NSAttributedString alloc] initWithString:_author]];
        [_authorAndBody addAttribute:NSForegroundColorAttributeName value:[UIColor nameColor] range:NSMakeRange(0, _author.length)];
        [_authorAndBody appendAttributedString:[[NSAttributedString alloc] initWithString:@"："]];
        [_authorAndBody appendAttributedString:[Utils emojiStringFromRawString:_body]];
        return _authorAndBody;
    }
}

@end
