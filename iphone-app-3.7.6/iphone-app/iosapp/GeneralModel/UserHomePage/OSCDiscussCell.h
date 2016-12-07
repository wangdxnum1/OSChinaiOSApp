//
//  OSCDiscussCell.h
//  iosapp
//
//  Created by Graphic-one on 16/9/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCDiscuss;
@interface OSCDiscussCell : UITableViewCell

+ (instancetype)returnReuseDiscussCellWithTableView:(UITableView* )tableView
                                          indexPath:(NSIndexPath* )indexPath
                                         identifier:(NSString* )reuseIdentifier;


@property (nonatomic,strong) OSCDiscuss* discuss;

@end
