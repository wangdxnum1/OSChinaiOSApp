//
//  OSCThread.m
//  iosapp
//
//  Created by ChanAetern on 3/1/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "OSCThread.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "OSCNotice.h"

#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <Reachability.h>
#import <MJExtension.h>

static BOOL isPollingStarted;
static NSTimer *timer;
static Reachability *reachability;

@interface OSCThread ()

@end

@implementation OSCThread

+ (void)startPollingNotice
{
    if (isPollingStarted) {
        return;
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
        reachability = [Reachability reachabilityWithHostName:@"www.oschina.net"];
        isPollingStarted = YES;
    }
}

+ (void)timerUpdate
{
    if (reachability.currentReachabilityStatus == 0) {return;}
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@notice", OSCAPI_V2_PREFIX];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             NSInteger code = [responseObject[@"code"] integerValue];
             if (code == 1) {
                 NSDictionary *result = responseObject[@"result"];
                 OSCNotice *newNotice = [OSCNotice mj_objectWithKeyValues:result];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:OSCAPI_USER_NOTICE
                                                                     object:@[@(newNotice.mention), @(newNotice.review), @(newNotice.letter), @(newNotice.fans), @(newNotice.like)]];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

@end
