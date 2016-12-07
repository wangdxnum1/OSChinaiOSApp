//
//  OSCTextTweetCell.h
//  iosapp
//
//  Created by Graphic-one on 16/8/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "AsyncDisplayTableViewCell.h"
@class OSCTweetItem;
@interface OSCTextTweetCell : AsyncDisplayTableViewCell

+ (instancetype)returnReuseTextTweetCellWithTableView:(UITableView* )tableView
                                            identifier:(NSString* )reuseIdentifier;

@property (nonatomic,strong) OSCTweetItem* tweetItem;

@property (nonatomic,weak) id<AsyncDisplayTableViewCellDelegate> delegate;

@end
