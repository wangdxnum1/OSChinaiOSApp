//
//  AFHTTPRequestOperationManager+Util.m
//  iosapp
//
//  Created by AeternChan on 6/18/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIDevice+SystemInfo.h"
#import <AFOnoResponseSerializer.h>
#import <UIKit/UIKit.h>

@implementation AFHTTPRequestOperationManager (Util)

+ (instancetype)OSCManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer XMLResponseSerializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager.requestSerializer setValue:[self generateUserAgent] forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:Application_AppToken forHTTPHeaderField:@"AppToken"];//AppToken

    return manager;
}

+ (instancetype)OSCJsonManager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager.requestSerializer setValue:[self generateUserAgent] forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:Application_AppToken forHTTPHeaderField:@"AppToken"];//AppToken
    
    return manager;
}

/** UA : "OSChina.NET/1.0 (oscapp; %s; iPhone %s; %s; %s)" */
+ (NSString *)generateUserAgent
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString* systemVersion = [UIDevice currentDevice].systemVersion;
    NSString* deviceCateory = kDeviceArray[[UIDevice currentDeviceResolution]];
    NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //OSChina.NET/3.7.5/iOS/10.0/iPhone/F5ACDFD8-A488-4EA6-A545-003427AFA300
    NSString* UA = [NSString stringWithFormat:@"OSChina.NET/1.0 (oscapp; %@; iPhone %@; %@; %@)",appVersion,systemVersion,deviceCateory,UUID];

    return UA;
}

@end
