//
//  TweetsDetailNewCell.h
//  iosapp
//
//  Created by Holden on 16/6/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetsDetailNewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *portraitIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *platformLabel;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@property (weak, nonatomic) IBOutlet UIImageView *likeTagIv;
@property (weak, nonatomic) IBOutlet UILabel *intervalTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentTagIv;
@end
