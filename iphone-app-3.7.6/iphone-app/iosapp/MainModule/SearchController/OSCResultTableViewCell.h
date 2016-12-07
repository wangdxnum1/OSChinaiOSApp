//
//  OSCResultTableViewCell.h
//  iosapp
//
//  Created by 王恒 on 16/10/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCResultCoustomCell : UITableViewCell

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *content;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

@class OSCSearchPeopleItem;
@interface OSCResultPersonCell : UITableViewCell

@property (nonatomic,strong) OSCSearchPeopleItem *model;

@end
