//
//  OSCListNomalCell.h
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOSCListNomalCellReuseIdentifier @"OSCListNomalCell"

@class OSCListItem;
@interface OSCListNomalCell : UITableViewCell

+ (instancetype)returnListNomalCellWithTableView:(UITableView* )tableView
                                       indexPath:(NSIndexPath* )indexPath
                                   identifierStr:(NSString* )identifier;

@property (nonatomic,strong) OSCListItem* listItem;

@end
