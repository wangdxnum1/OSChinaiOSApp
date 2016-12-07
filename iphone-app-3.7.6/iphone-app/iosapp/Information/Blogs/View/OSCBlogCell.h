//
//  OSCBlogCell.h
//  iosapp
//
//  Created by 李萍 on 2016/11/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kNewHotBlogTableViewCellReuseIdentifier @"OSCBlogCell"
@class OSCListItem;
@interface OSCBlogCell : UITableViewCell

+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString;

@property (nonatomic,strong) OSCListItem* listItem;

@end
