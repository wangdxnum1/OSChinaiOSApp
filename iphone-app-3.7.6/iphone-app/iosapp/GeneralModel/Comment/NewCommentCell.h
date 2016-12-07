//
//  NewCommentCell.h
//  iosapp
//
//  Created by 李萍 on 16/6/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"
#import "OSCCommentItem.h"
#import "OSCNewComment.h"

@interface NewCommentCell : UITableViewCell

@property (strong, nonatomic) UIImageView *commentPortrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
//@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UITextView *contentTextView;
@property (strong, nonatomic) UILabel *voteLabel;
@property (strong, nonatomic) UIImageView *voteImageView;
@property (strong, nonatomic) UIButton *commentButton;
@property (nonatomic, strong) UIImageView *bestImageView;

@property (nonatomic, strong) UIView *referCommentView;

@property (nonatomic, strong) OSCCommentItem *comment;

- (void)setDataForQuestionComment:(OSCCommentItem *)questComment;

- (void)setDataForQuestionCommentReply:(OSCNewCommentReply *)commentReply;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end

