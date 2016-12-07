//
//  ContentWKWebViewCell.m
//  iosapp
//
//  Created by Graphic-one on 16/7/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ContentWKWebViewCell.h"
#import "IMYWebView.h"
#import <Masonry.h>

@implementation ContentWKWebViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        IMYWebView* contentWebView = [[IMYWebView alloc] initWithFrame:CGRectZero usingUIWebView:NO];
        contentWebView.userInteractionEnabled = YES;
        [contentWebView.scrollView setBounces:NO];
        [contentWebView.scrollView setScrollEnabled:NO];
        [self.contentView addSubview:contentWebView];
        
        [contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(16);
            make.top.equalTo(self.contentView).with.offset(4);
            make.right.and.bottom.equalTo(self.contentView).with.offset(-16);
        }];
        _contentWebView = contentWebView;
    }
    return self;
}



@end
