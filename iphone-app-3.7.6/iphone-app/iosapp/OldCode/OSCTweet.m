//
//  OSCTweet.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "OSCTweet.h"
#import "OSCUser.h"
#import "Utils.h"
#import <UIKit/UIKit.h>

static NSString * const kID = @"id";
static NSString * const kPortrait = @"portrait";
static NSString * const kAuthor = @"author";
static NSString * const kAuthorID = @"authorid";
static NSString * const kBody = @"body";
static NSString * const kAppclient = @"appclient";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kPubDate = @"pubDate";
static NSString * const kImgSmall = @"imgSmall";
static NSString * const kImgBig = @"imgBig";
static NSString * const kAttach = @"attach";

static NSString * const kLikeCount = @"likeCount";
static NSString * const kIsLike = @"isLike";
static NSString * const kLikeList = @"likeList";
static NSString * const kUser = @"user";


@implementation OSCTweet

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _tweetID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        
        _body = [[xml firstChildWithTag:kBody] stringValue];
        _appclient = [[[xml firstChildWithTag:kAppclient] numberValue] intValue];
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:kPubDate].stringValue];
        _pubDateString = [[xml firstChildWithTag:kPubDate] stringValue];
        
        // 附图
        NSString *imageURLStr = [[xml firstChildWithTag:kImgSmall] stringValue];
        _hasAnImage = ![imageURLStr isEqualToString:@""];
        _smallImgURL = [NSURL URLWithString:imageURLStr];
        _bigImgURL = [NSURL URLWithString:[[xml firstChildWithTag:kImgBig] stringValue]];
        
        // 语音信息
        _attach = [[xml firstChildWithTag:kAttach] stringValue];
        
        // 点赞
        _likeCount = [[[xml firstChildWithTag:kLikeCount] numberValue] intValue];
        _isLike = [[[xml firstChildWithTag:kIsLike] numberValue] boolValue];
        
        _likeList = [NSMutableArray new];
        NSArray *likeListXML = [[xml firstChildWithTag:kLikeList] childrenWithTag:kUser];
        for (ONOXMLElement *userXML in likeListXML) {
            OSCUser *user = [[OSCUser alloc] initWithXML:userXML];
            [_likeList addObject:user];
        }
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _tweetID == ((OSCTweet *)object).tweetID;
    }
    
    return NO;
}

- (NSMutableAttributedString *)likersDetailString
{
    if (!_likersDetailString) {
        _likersDetailString = [NSMutableAttributedString new];
        
        if (_likeList.count > 0) {
            for (int names = 0; names < 10 && names < _likeList.count; names++) {
                OSCUser *user = _likeList[names];   //_likeList[_likeCount - 1 - names];
                
                [_likersDetailString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@、", user.name]]];
            }
            [_likersDetailString deleteCharactersInRange:NSMakeRange(_likersDetailString.length - 1, 1)];
            //设置颜色
            [_likersDetailString addAttribute:NSForegroundColorAttributeName value:[UIColor nameColor] range:NSMakeRange(0, _likersDetailString.length)];
            
            if (_likeCount > 10) {
                [_likersDetailString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"等%d人", _likeCount]]];
            }
            
            [_likersDetailString appendAttributedString:[[NSAttributedString alloc] initWithString:@"觉得很赞"]];
        } else {
            [_likersDetailString deleteCharactersInRange:NSMakeRange(0, _likersDetailString.length)];
            [_likersDetailString appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];
        }

    }
    return _likersDetailString;
}
 

- (NSMutableAttributedString *)likersString
{
    if (!_likersString) {
        _likersString = [NSMutableAttributedString new];
        
        if (_likeList.count > 0) {
            for (int names = 0; names < 3 && names < _likeList.count; names++) {
                OSCUser *user = _likeList[names];   //_likeList[_likeCount - 1 - names];
                
                [_likersString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@、", user.name]]];
            }
            [_likersString deleteCharactersInRange:NSMakeRange(_likersString.length - 1, 1)];
            //设置颜色
            [_likersString addAttribute:NSForegroundColorAttributeName value:[UIColor nameColor] range:NSMakeRange(0, _likersString.length)];
            
            if (_likeCount > 3) {
                [_likersString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"等%d人", _likeCount]]];
            }
            
            [_likersString appendAttributedString:[[NSAttributedString alloc] initWithString:@"觉得很赞"]];
        } else {
            [_likersString deleteCharactersInRange:NSMakeRange(0, _likersString.length)];
            [_likersString appendAttributedString:[[NSAttributedString alloc] initWithString:@""]];
        }
    }
    
    return _likersString;
}


- (NSAttributedString *)attributedCommentCount
{
    if (!_attributedCommentCount) {
        _attributedCommentCount = [Utils attributedCommentCount:_commentCount];
    }
    
    return _attributedCommentCount;
}

@end
