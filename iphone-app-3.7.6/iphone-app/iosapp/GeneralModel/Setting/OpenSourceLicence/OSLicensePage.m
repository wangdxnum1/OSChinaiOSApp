//
//  OSLicensePage.m
//  iosapp
//
//  Created by chenhaoxiang on 3/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSLicensePage.h"

@implementation OSLicensePage

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"开源组件";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    webView.scrollView.bounces = NO;
    

    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"OSLicense"
                                                                                                             ofType:@"html"
                                                                                                        inDirectory:@"html"]]]];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
