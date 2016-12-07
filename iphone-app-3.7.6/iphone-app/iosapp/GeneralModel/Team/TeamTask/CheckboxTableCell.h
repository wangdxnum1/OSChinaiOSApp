//
//  CheckboxTableCell.h
//  iosapp
//
//  Created by chenhaoxiang on 5/25/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CellType)
{
    CellTypeProject,
    CellTypeIssue,
    CellTypeMember,
    CellTypeTime,
};

@interface CheckboxTableCell : UITableViewCell

@property (nonatomic, strong) UILabel *descriptionLabel;

- (id)initWithCellType:(CellType)type;

@end
