//
//  WKDelegateController.m
//  iosapp
//
//  Created by Graphic-one on 16/10/20.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "WKDelegateController.h"



@implementation WKDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end
