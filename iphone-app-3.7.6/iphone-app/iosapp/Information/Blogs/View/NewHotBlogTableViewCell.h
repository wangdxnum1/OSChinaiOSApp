//
//  NewHotBlogTableViewCell.h
//  iosapp
//
//  Created by Holden on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsualTableViewCell.h"

#define kNewHotBlogTableViewCellReuseIdentifier @"NewHotBlogTableViewCell"

@class OSCNewHotBlog , OSCListItem;
@interface NewHotBlogTableViewCell : UsualTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;

@property (nonatomic, strong) OSCNewHotBlog *blog;

@property (nonatomic, strong) OSCListItem* listItem;

+ (instancetype)returnReuseNewHotBlogCellWithTableView:(UITableView* )tableView
                                             indexPath:(NSIndexPath* )indexPath
                                            identifier:(NSString* )reuseIdentifier;

//- (void)setNewHotBlogContent:(OSCNewHotBlog *)blog;

@end
