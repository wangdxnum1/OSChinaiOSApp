//
//  OSCInformation.m
//  iosapp
//
//  Created by Graphic-one on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformation.h"
#import <UIKit/UIKit.h>
#import "NSTextAttachment+Util.h"

@implementation OSCInformation

- (NSMutableAttributedString *)attributedBody{
    if (_attributedBody == nil) {
        _attributedBody = [NSMutableAttributedString new];
        
        if (self.recommend) {
            NSTextAttachment* textAttachment = [[NSTextAttachment alloc]init];
            textAttachment.image = [UIImage imageNamed:@"ic_label_today"];
            [textAttachment adjustY:-3];
            NSAttributedString* attachMentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [_attributedBody appendAttributedString:attachMentString];
            [_attributedBody appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        }
        
        [_attributedBody appendAttributedString:[[NSAttributedString alloc] initWithString:self.body]];
        
    }
    return _attributedBody;
}
@end
