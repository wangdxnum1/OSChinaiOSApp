//
//  TweetCell.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-14.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCTweet;

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentCount;
@property (nonatomic, strong) UILabel *appclientLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *likeListLabel;
@property (nonatomic, strong) UIImageView *thumbnail;

@property (nonatomic, strong) NSArray *thumbnailConstraints;
@property (nonatomic, strong) NSArray *noThumbnailConstraints;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);
@property (nonatomic, copy) void (^deleteObject)(UITableViewCell *cell);


- (void)setContentWithTweet:(OSCTweet *)tweet;
- (void)copyText:(id)sender;
- (void)deleteObject:(id)sender;

+ (void)initContetTextView:(UITextView*)textView;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end
