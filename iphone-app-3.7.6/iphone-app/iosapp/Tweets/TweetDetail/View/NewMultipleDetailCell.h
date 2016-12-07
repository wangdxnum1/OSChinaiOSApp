//
//  NewMultipleDetailCell.h
//  iosapp
//
//  Created by Graphic-one on 16/7/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewMultipleDetailCell , OSCPhotoGroupView;
@protocol NewMultipleDetailCellDelegate <NSObject>

- (void) userPortraitDidClick:(NewMultipleDetailCell* )multipleTweetCell
                  tapGestures:(UITapGestureRecognizer* )tap;

- (void) commentButtonDidClick:(NewMultipleDetailCell* )multipleTweetCell
                   tapGestures:(UITapGestureRecognizer* )tap;

- (void) likeButtonDidClick:(NewMultipleDetailCell* )multipleTweetCell
                   tapGestures:(UITapGestureRecognizer* )tap;

- (void) assemblyMultipleTweetCellDidFinsh:(NewMultipleDetailCell* )multipleTweetCell;

- (void) loadLargeImageDidFinsh:(NewMultipleDetailCell* )multipleTweetCell
                 photoGroupView:(OSCPhotoGroupView* )groupView
                       fromView:(UIImageView* )fromView;

- (void) shouldInteractTextView:(UITextView* )textView
                            URL:(NSURL *)URL
                        inRange:(NSRange)characterRange;
@end


@class OSCTweetItem;
@interface NewMultipleDetailCell : UITableViewCell

- (instancetype) initWithTweetItem:(OSCTweetItem* )item
                   reuseIdentifier:(NSString* )reuseIdentifier;

+ (instancetype) multipleDetailCellWith:(OSCTweetItem* )item
                        reuseIdentifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) OSCTweetItem* item;

@property (nonatomic,weak) id<NewMultipleDetailCellDelegate> delegate;

/** Lock initialization routine method */
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
