//
//  EventCell.h
//  iosapp
//
//  Created by ChanAetern on 12/1/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kEventWitImageCellID = @"EventCellWithImage";
static NSString * const kEventWithReferenceCellID = @"EventCellWithReference";
static NSString * const kEventWithoutExtraInfoCellID = @"EventCellWithoutExtraInfo";

@class OSCEvent;

@interface EventCell : UITableViewCell

@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UITextView *contentTextView;

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UITextView *referenceText;
@property (nonatomic, strong) UILabel *appclientLabel;
@property (nonatomic, strong) UILabel *commentCount;
@property (nonatomic, strong) UIView *extraInfoView;

@property (nonatomic, copy) BOOL (^canPerformAction)(UITableViewCell *cell, SEL action);

- (void)setContentWithEvent:(OSCEvent *)event;
- (void)copyText:(id)sender;

+ (void)initContetTextView:(UITextView*)textView;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;

@end
