//
//  EmojiPanelVC.h
//  iosapp
//
//  Created by ChanAetern on 12/21/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiPanelVC : UIViewController

- (instancetype)initWithPageIndex:(int)pageIndex;

@property (nonatomic, readonly, assign) int pageIndex;
@property (nonatomic, copy) void (^didSelectEmoji)(NSTextAttachment *textAttachment);
@property (nonatomic, copy) void (^deleteEmoji)();

@end
