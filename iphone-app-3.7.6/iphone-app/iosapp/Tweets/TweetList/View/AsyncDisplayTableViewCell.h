//
//  AsyncDisplayTableViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#define kScreen_W [UIScreen mainScreen].bounds.size.width

#define padding_top 16
#define padding_left 16
#define padding_right padding_left
#define padding_bottom padding_top

//< SPACE代表水平距离 space代表垂直距离
#define userPortrait_W 44
#define userPortrait_H 44
#define userPortrait_SPACE_nameLabel 10
#define descTextView_SPACE_userPortrait 10
#define nameLabel_H 16
#define nameLabel_space_descTextView 4
#define descTextView_space_imageView 10
#define descTextView_space_timeAndSourceLabel 2
#define imageView_space_timeAndSourceLabel 8
#define timeAndSourceLabel_W 190
#define timeAndSourceLabel_H 14
#define commentCountLabel_W 24
#define commentCountLabel_H 14
#define operationBtn_space_label 4
#define like_space_comment 3
#define separatorLine_H 0.5
#define operationBtn_W 18
#define operationBtn_H 16

//< font size
#define nameLabel_FontSize 15
#define descTextView_FontSize 14

//< MultipleImage size

#import <UIKit/UIKit.h>
@class AsyncDisplayTableViewCell,OSCPhotoGroupView;
@protocol AsyncDisplayTableViewCellDelegate <NSObject>

- (void)userPortraitDidClick:(__kindof AsyncDisplayTableViewCell* )cell;

- (void)changeTweetStausButtonDidClick:(__kindof AsyncDisplayTableViewCell* )cell;

- (void)shouldInteractTextView:(UITextView* )textView
                           URL:(NSURL *)URL
                       inRange:(NSRange)characterRange;

- (void)textViewTouchPointProcessing:(UITapGestureRecognizer* )tap;

@optional
- (void)loadLargeImageDidFinsh:(__kindof AsyncDisplayTableViewCell *)cell
                photoGroupView:(OSCPhotoGroupView *)groupView
                      fromView:(UIImageView *)fromView;

@end

@interface AsyncDisplayTableViewCell : UITableViewCell

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);

@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);

- (void)handleTextView:(UITextView* )textView;

- (void)copyText:(id)sender;

- (UIImage* )likeImage;

- (UIImage* )unlikeImage;

- (UIImage* )commentImage;

- (UIImage* )gifImage;

- (void)setLikeStatus:(BOOL)isLike animation:(BOOL)isNeedAnimation;


@end



