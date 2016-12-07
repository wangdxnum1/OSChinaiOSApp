//
//  OSCAtMeCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCAtMeCell;
@protocol OSCAtMeCellDelegate <NSObject>

- (void)atMeCellDidClickUserPortrait:(OSCAtMeCell* )cell;

- (void)shouldInteractTextView:(UITextView* )textView
                           URL:(NSURL *)URL
                       inRange:(NSRange)characterRange;

- (void)textViewTouchPointProcessing:(UITapGestureRecognizer* )tap;

@end

@class AtMeItem;
@interface OSCAtMeCell : UITableViewCell
+ (instancetype)returnReuseAtMeCellWithTableView:(UITableView* )tableView
                                       indexPath:(NSIndexPath* )indexPath
                                      identifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) AtMeItem* atMeItem;

@property (nonatomic,weak) id<OSCAtMeCellDelegate> delegate;

@end
