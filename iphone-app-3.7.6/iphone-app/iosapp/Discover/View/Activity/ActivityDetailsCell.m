//
//  ActivityDetailsCell.m
//  iosapp
//
//  Created by ChanAetern on 1/26/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ActivityDetailsCell.h"
#import "UIColor+Util.h"

@implementation ActivityDetailsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor themeColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubviews
{
    _webView = [UIWebView new];
    _webView.scrollView.bounces = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor themeColor];
    [self.contentView addSubview:_webView];}

- (void)setLayout
{
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_webView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_webView]|"   options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:views]];
}

@end
