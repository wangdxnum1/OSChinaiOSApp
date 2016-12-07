//
//  OSCNewHotBlog.m
//  iosapp
//
//  Created by Holden on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNewHotBlog.h"
#import "Utils.h"

@implementation OSCNewHotBlog

- (NSMutableAttributedString *)attributedTitleString
{
    if (_attributedTitleString == nil) {
        
        _attributedTitleString = [NSMutableAttributedString new];
        if (self.recommend) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"ic_label_recommend"];
            [textAttachment adjustY:-3];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            _attributedTitleString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        }
        if (self.original) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"ic_label_originate"];
            [textAttachment adjustY:-3];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [_attributedTitleString appendAttributedString:attachmentString];
        } else {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:@"ic_label_reprint"];
            [textAttachment adjustY:-3];
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [_attributedTitleString appendAttributedString:attachmentString];
            
        }
        [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        if (self.title.length > 0) {
            [_attributedTitleString appendAttributedString:[[NSAttributedString alloc] initWithString:self.title]];
        }
        
        
    }
    return _attributedTitleString;
}


@end
