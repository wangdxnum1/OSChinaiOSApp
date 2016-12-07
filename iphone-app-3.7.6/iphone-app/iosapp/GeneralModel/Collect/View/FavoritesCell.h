//
//  FavoritesCell.h
//  iosapp
//
//  Created by 李萍 on 2016/10/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCFavorites.h"

@interface FavoritesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeLable;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *favCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, strong) OSCFavorites *favorite;

@end
