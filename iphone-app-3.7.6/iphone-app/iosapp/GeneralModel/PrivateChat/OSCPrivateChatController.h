//
//  OSCPrivateChatController.h
//  iosapp
//
//  Created by Graphic-one on 16/8/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCPrivateChatController : UITableViewController

@property (nonatomic, copy) void (^didScroll)();

- (instancetype)initWithAuthorId:(NSInteger)authorId;

- (void)refresh;

@end
