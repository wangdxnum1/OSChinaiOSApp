//
//  SoftWareDetailBodyCell.h
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCNewSoftWare;
@interface SoftWareDetailBodyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIWebView *webView;

-(void)configurationRelatedInfo:(OSCNewSoftWare* )softWareModel;

@end
