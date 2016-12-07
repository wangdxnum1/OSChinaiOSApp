//
//  InformationTableViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/5/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsualTableViewCell.h"

extern NSString* InformationTableViewCell_IdentifierString;

@class OSCInformation , OSCListItem;
@interface InformationTableViewCell : UsualTableViewCell

+(instancetype)returnReuseCellFormTableView:(UITableView* )tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString;

@property (nonatomic,strong) OSCInformation* viewModel;

@property (nonatomic,strong) OSCListItem* listItem;

@property (nonatomic, copy) NSString *systemTimeDate;

@end

