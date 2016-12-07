//
//  ProjectCell.h
//  iosapp
//
//  Created by Holden on 15/4/27.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TeamProject;

@interface ProjectCell : UITableViewCell

- (void)setContentWithTeamProject:(TeamProject *)project;

@end
