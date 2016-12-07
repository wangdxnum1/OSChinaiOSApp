//
//  TweetEditingVC.h
//  iosapp
//
//  Created by ChanAetern on 12/18/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetEditingVC : UIViewController

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithTopic:(NSString *)TopicName;

- (instancetype)initWithTeamID:(int)teamID;

- (void)insertString:(NSString *)string andSelect:(BOOL)shouldSelect;

//- (instancetype)initWithImages:(NSMutableArray *)images;
@end
