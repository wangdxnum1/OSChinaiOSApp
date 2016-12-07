//
//  TeamCell.m
//  iosapp
//
//  Created by AeternChan on 4/28/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TeamCell.h"
#import "Utils.h"

#define MARGIN 7

@implementation TeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        [self setCornerRadius:3];
        self.backgroundColor = [UIColor colorWithHex:0x555555];
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0x333333];
        self.selectedBackgroundView = selectedBackground;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.x += MARGIN;
    frame.size.width -= 2 * MARGIN;
    [super setFrame:frame];
}

@end
