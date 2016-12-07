//
//  TimeLineNodeCell.h
//  iosapp
//
//  Created by AeternChan on 5/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineNodeCell : UITableViewCell

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UIView *upperLine;
@property (nonatomic, strong) UIView *underLine;

- (void)setContentWithString:(NSAttributedString *)HTML;

@end
