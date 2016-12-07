//
//  OSCInformationTableViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define InformationTableViewCell_IdentifierString @"InformationTableViewCellReuseIdenfitier"

@class OSCListItem;
@interface OSCInformationTableViewCell : UITableViewCell

+(instancetype)returnReuseCellFormTableView:(UITableView *)tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString;

@property (nonatomic,strong) OSCListItem* listItem;

@property (nonatomic,assign,getter=isShowCommentCount) BOOL showCommentCount;

@end
