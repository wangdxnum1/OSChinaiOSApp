//
//  InputToolbarContentView.m
//  zbapp
//
//  Created by AeternChan on 7/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "InputToolbarContentView.h"
#import "UIColor+Util.h"

@implementation InputToolbarContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _editingView.layer.borderColor = [UIColor colorWithHex:0xC8C8CD].CGColor;
}

@end
