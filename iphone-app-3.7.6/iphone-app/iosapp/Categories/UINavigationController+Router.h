//
//  UINavigationController+Router.h
//  iosapp
//
//  Created by AeternChan on 10/14/15.
//  Copyright © 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Router)

- (void)handleURL:(NSURL *)url
             name:(NSString* )name;

@end
