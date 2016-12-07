//
//  OSCCommentItem.m
//  iosapp
//
//  Created by Holden on 16/7/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentItem.h"
#import "Utils.h"



@implementation OSCCommentItem

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

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"refer" : [OSCCommentItemRefer class],
             @"reply" : [OSCCommentItemReply class],
             
             };
}

@end

//引用
@implementation OSCCommentItemRefer

@end


//回复
@implementation OSCCommentItemReply

@end
