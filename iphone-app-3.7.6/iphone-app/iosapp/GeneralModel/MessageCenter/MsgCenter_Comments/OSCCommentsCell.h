//
//  OSCCommentsCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OSCCommentsCell;
@protocol OSCCommentsCellDelegate <NSObject>

- (void)commentsCellDidClickUserPortrait:(OSCCommentsCell* )cell;

- (void)shouldInteractTextView:(UITextView* )textView
                           URL:(NSURL *)URL
                       inRange:(NSRange)characterRange;

- (void)textViewTouchPointProcessing:(UITapGestureRecognizer* )tap;

@end

@class CommentItem;
@interface OSCCommentsCell : UITableViewCell
+ (instancetype)returnReuseCommentsCellWithTableView:(UITableView* )tableView
                                           indexPath:(NSIndexPath* )indexPath
                                          identifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) CommentItem* commentItem;

@property (nonatomic,weak) id<OSCCommentsCellDelegate> delegate;

@end
