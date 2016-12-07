//
//  NSDate+Util.h
//  iosapp
//
//  Created by AeternChan on 10/15/15.
//  Copyright © 2015 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DateTools.h>

@interface NSDate (Util)

+ (instancetype)dateFromString:(NSString *)string;
- (NSString *)weekdayString;

@end
