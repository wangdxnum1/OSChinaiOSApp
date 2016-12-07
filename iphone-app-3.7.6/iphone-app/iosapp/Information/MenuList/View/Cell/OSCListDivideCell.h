//
//  OSCListDivideCell.h
//  iosapp
//
//  Created by Graphic-one on 16/10/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOSCListDivideCellReuseIdentifier @"OSCListDivideCell"

@class OSCListItem;
@interface OSCListDivideCell : UITableViewCell

+ (instancetype)returnListDivideCellWithTableView:(UITableView* )tableView
                                        indexPath:(NSIndexPath* )indexPath
                                    identifierStr:(NSString* )identifier;

@property (nonatomic,strong) OSCListItem* listItem;

@end
