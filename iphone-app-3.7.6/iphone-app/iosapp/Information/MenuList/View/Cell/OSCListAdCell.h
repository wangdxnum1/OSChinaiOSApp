//
//  OSCListAdCell.h
//  iosapp
//
//  Created by Graphic-one on 16/10/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOSCListAdCellReuseIdentifier @"OSCListAdCell"

@class OSCListItem;
@interface OSCListAdCell : UITableViewCell

+ (instancetype)returnListAdCellWithTableView:(UITableView* )tableView
                                    indexPath:(NSIndexPath* )indexPath
                                identifierStr:(NSString* )identifier;

@property (nonatomic,strong) OSCListItem* listItem;

@end
