//
//  QuesAnsTableViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/5/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsualTableViewCell.h"

#define kQuesAnsTableViewCellReuseIdentifier @"QuesAnsTableViewCell"

@class OSCQuestion,OSCListItem;
@interface QuesAnsTableViewCell : UsualTableViewCell

@property (nonatomic,strong) OSCQuestion* viewModel;

@property (nonatomic,strong) OSCListItem* listItem;

@end
