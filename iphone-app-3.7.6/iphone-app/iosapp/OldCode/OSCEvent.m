//
//  OSCEvent.m
//  iosapp
//
//  Created by chenhaoxiang on 11/29/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "OSCEvent.h"
#import "Utils.h"
#import <UIKit/UIKit.h>

static NSString * const kID = @"id";
static NSString * const kMessage = @"message";
static NSString * const kTweetImg = @"tweetimage";

static NSString * const kAuthorID = @"authorid";
static NSString * const kAuthor = @"author";
static NSString * const kPortrait = @"portrait";

static NSString * const kCatalog = @"catalog";
static NSString * const kAppClient = @"appclient";
static NSString * const kCommentCount = @"commentCount";
static NSString * const kPubDate = @"pubDate";

static NSString * const kObjectType = @"objecttype";
static NSString * const kObjectTitle = @"objecttitle";
static NSString * const kObjectID = @"objectid";
static NSString * const kObjectReply = @"objectreply";
static NSString * const kObjectName = @"objectname";
static NSString * const kObjectBody = @"objectbody";
static NSString * const kObjectCatalog = @"objectcatalog";

@interface OSCEvent()

@property (nonatomic, strong) NSMutableAttributedString *actionStr;

@end


@implementation OSCEvent

- (instancetype)initWithXML:(ONOXMLElement *)xml
{
    if (self = [super init]) {
        _eventID = [[[xml firstChildWithTag:kID] numberValue] longLongValue];
        _message = [[[xml firstChildWithTag:kMessage] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _tweetImg = [NSURL URLWithString:[[xml firstChildWithTag:kTweetImg] stringValue]];
        
        _authorID = [[[xml firstChildWithTag:kAuthorID] numberValue] longLongValue];
        _author = [[xml firstChildWithTag:kAuthor] stringValue];
        _portraitURL = [NSURL URLWithString:[[xml firstChildWithTag:kPortrait] stringValue]];
        
        _catalog = [[[xml firstChildWithTag:kCatalog] numberValue] intValue];
        _appclient = [[[xml firstChildWithTag:kAppClient] numberValue] intValue];
        _commentCount = [[[xml firstChildWithTag:kCommentCount] numberValue] intValue];
        _pubDate = [NSDate dateFromString:[xml firstChildWithTag:kPubDate].stringValue];
        
        _objectID = [[[xml firstChildWithTag:kObjectID] numberValue] longLongValue];
        _objectType = [[[xml firstChildWithTag:kObjectType] numberValue] intValue];
        _objectCatalog = [[[xml firstChildWithTag:kObjectCatalog] numberValue] intValue];
        _objectTitle = [[xml firstChildWithTag:kObjectTitle] stringValue];
        
        ONOXMLElement *objectReply = [xml firstChildWithTag:kObjectReply];
        NSString *objectName = [[objectReply firstChildWithTag:kObjectName] stringValue] ?: @"";
        NSString *objectBody = [[objectReply firstChildWithTag:kObjectBody] stringValue] ?: @"";
        _objectReply = @[objectName,
                         [objectBody stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        _hasAnImage = ![_tweetImg.absoluteString isEqualToString:@""];
        _hasReference = ![_objectReply[1] isEqualToString:@""];
        _shouleShowClientOrCommentCount = (_appclient != 0 && _appclient != 1) || _commentCount > 0;
    }
    
    return self;
}


- (NSMutableAttributedString *)actionStr
{
    if (_actionStr) {return _actionStr;}
    
    NSDictionary *actionStrAttributes = @{
                                          NSFontAttributeName:[UIFont systemFontOfSize:14],
                                          NSForegroundColorAttributeName:[UIColor grayColor]
                                          };
    
    NSDictionary *objectTitleAttributes = @{
                                            NSFontAttributeName:[UIFont systemFontOfSize:14],
                                            NSForegroundColorAttributeName:[UIColor nameColor]
                                            };
    
    _actionStr = [NSMutableAttributedString alloc];
    
    switch (_objectType) {
        case 1:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"添加了开源项目 " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            }
            break;
        case 2:
            if (_objectCatalog == 1) {
                _actionStr = [_actionStr initWithString:@"在讨论区提问 " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            } else if(_objectCatalog == 2) {
                _actionStr = [_actionStr initWithString:@"发表了新话题 " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            }
            break;
        case 3:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"发表了博客 " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            }
            break;
        case 4:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"发表一篇新闻 " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            }
            break;
        case 5:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"分享了一段代码 " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            }
            break;
        case 6:
            _actionStr = [_actionStr initWithString:@"发布了一个职位 " attributes:actionStrAttributes];
            [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            break;
        case 16:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"在新闻  发表评论" attributes:actionStrAttributes];
                [_actionStr insertAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes] atIndex:4];
            }
            break;
        case 17:
            if (_objectCatalog == 1) {
                _actionStr = [_actionStr initWithString:@"回答了问题: " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            } else if(_objectCatalog == 2){
                _actionStr = [_actionStr initWithString:@"回复了话题: " attributes:actionStrAttributes];
                [_actionStr appendAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes]];
            } else if(_objectCatalog == 3){
                _actionStr = [_actionStr initWithString:@"在  对回帖发表评论" attributes:actionStrAttributes];
                [_actionStr insertAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes] atIndex:2];
            }
            break;
        case 18:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"在博客  发表评论" attributes:actionStrAttributes];
                [_actionStr insertAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes] atIndex:4];
            }
            break;
        case 19:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"在代码  发表评论" attributes:actionStrAttributes];
                [_actionStr insertAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes] atIndex:4];
            }
            break;
        case 20:
            _actionStr = [_actionStr initWithString:@"在职位  发表评论:" attributes:actionStrAttributes];
            [_actionStr insertAttributedString:[[NSAttributedString alloc] initWithString:_objectTitle attributes:objectTitleAttributes] atIndex:4];
            break;
        case 32:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"加入了开源中国" attributes:actionStrAttributes];
            }
            break;
        case 100:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"更新了动态" attributes:actionStrAttributes];
            }
            break;
        case 101:
            if (_objectCatalog == 0) {
                _actionStr = [_actionStr initWithString:@"回复了动态:" attributes:actionStrAttributes];
            }
            break;
    }
    
    return _actionStr;
}


- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _eventID == ((OSCEvent *)object).eventID;
    }
    
    return NO;
}

-(NSAttributedString *)attributedCommentCount
{
    if (!_attributedCommentCount) {
        _attributedCommentCount = [Utils attributedCommentCount:_commentCount];
    }
    return _attributedCommentCount;
}

@end
