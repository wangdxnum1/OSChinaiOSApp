//
//  NSDate+Util.m
//  iosapp
//
//  Created by AeternChan on 10/15/15.
//  Copyright © 2015 oschina. All rights reserved.
//

#import "NSDate+Util.h"
#import "NSDateFormatter+Singleton.h"


static NSString * const kKeyYears = @"years";
static NSString * const kKeyMonths = @"months";
static NSString * const kKeyDays = @"days";
static NSString * const kKeyHours = @"hours";
static NSString * const kKeyMinutes = @"minutes";


@implementation NSDate (Util)

+ (instancetype)dateFromString:(NSString *)string
{
    return [[NSDateFormatter sharedInstance] dateFromString:string];
}

- (NSString *)weekdayString
{
    switch (self.weekday) {
        case 1: return @"星期天";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";
        default: return @"";
    }
}


@end
