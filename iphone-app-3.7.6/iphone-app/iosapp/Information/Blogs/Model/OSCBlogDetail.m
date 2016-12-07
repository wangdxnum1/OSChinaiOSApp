//
//  OSCBlogDetail.m
//  iosapp
//
//  Created by Graphic-one on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCBlogDetail.h"
#import <MJExtension.h>
#import <Myhpple/TFHpple.h>
#import "OSCModelHandler.h"

//#import <YYKit.h>

@implementation OSCBlogDetail

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"about" : [OSCBlogDetailRecommend class],
             @"comments" : [OSCNewComment class]
             };
}

+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{
             @"about" : [OSCBlogDetailRecommend class],
             @"comments" : [OSCNewComment class]
             };
}


@end

////
@implementation OSCBlogDetailRecommend


@end

//////
//@implementation OSCBlogDetailComment
//
//@end


////
//@implementation OSCBlogCommentRefer

//- (NSString *)trimmedContent
//{
//    if (!_trimmedContent) {
//        if (!_refer) {return nil;}
//        
//        _trimmedContent = [NSMutableString new];
//        
//        TFHpple *doc = [TFHpple hppleWithHTMLData:[_content dataUsingEncoding:NSUTF8StringEncoding]];
//        TFHppleElement *element = [doc peekAtSearchWithXPathQuery:@"/"];
//        _hrefs = [NSMutableArray new];
//        [self analyseHtmlElement:element];
//    }
//    
//    return _trimmedContent;
//}
//
//
//- (void)analyseHtmlElement:(TFHppleElement* )element
//{
//    if (element.isTextNode) {
//        if ([element.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
//            [_trimmedContent appendString:element.content];
//        } else if (![_trimmedContent hasSuffix:@"\n"] && _trimmedContent.length > 0){
//            NSCharacterSet *lineSet = [NSCharacterSet newlineCharacterSet];
//            if ([element.content rangeOfCharacterFromSet:lineSet].location != NSNotFound) {
//                [_trimmedContent appendString:@"\n"];
//            } else{
//                [_trimmedContent appendString:element.content];
//            }
//        }
//    } else if ([element.tagName isEqualToString:@"a"]) {
//        if (element.text.length > 0) {
//            
//            HrefMark *mark = [HrefMark new];
//            mark.href = [NSURL URLWithString:element.attributes[@"href"]];
//            mark.range = NSMakeRange(_trimmedContent.length, element.text.length);
//            
//            [_hrefs addObject:mark];
//        }
//    }
//    
//    if (element.hasChildren) {
//        for (TFHppleElement *child in [element children]) {
//            [self analyseHtmlElement:child];
//        }
//    }
//}
//

//@end

////
//@implementation HrefMark
//
//@end
