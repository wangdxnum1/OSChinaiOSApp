//
//  NSObject+Comment.m
//  iosapp
//
//  Created by Graphic-one on 16/11/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NSObject+Comment.h"
#import "Utils.h"
#import "Config.h"

@implementation NSObject (Comment)


@end



@implementation NSObject (Cache)

+ (NSString* )cacheResourceNameWithURL:(NSString* )requestUrl
               parameterDictionaryDesc:(nullable NSString* )paraDicDesc
{
    NSString* resourceName = [NSString stringWithFormat:@"%@%@%lld",requestUrl,paraDicDesc,[Config getOwnID]];
    return [Utils sha1:resourceName];
}

+ (NSString* )cacheBannerResourceNameWithURL:(NSString* )requestUrl
                               bannerCatalog:(OSCInformationListBannerType)catalog
{
    NSString* bannerResourceName = [NSString stringWithFormat:@"%@%ld%lld",requestUrl,catalog,[Config getOwnID]];
    return [Utils sha1:bannerResourceName];
}

/** 网络请求handle */
+ (BOOL)handleResponseObject:(id)responseObject resource:(NSString* )resourceName{
    if (!responseObject || !resourceName) { return NO; }
    if ([Config getOwnID] == 0) { return NO ;}
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* responseObjectData = (NSDictionary* )responseObject;
        if ([self createCacheFileWithResourceName:resourceName]) {
            NSString* path = [self cacheFilePathWithResourceName:resourceName];
            return [responseObjectData writeToFile:path atomically:YES];
        }else{
            return NO;
        }
    }
    
    if ([responseObject isKindOfClass:[NSArray class]]) {
        NSArray* responseObjectData = (NSArray* )responseObject;
        if ([self createCacheFileWithResourceName:resourceName]) {
            NSString* path = [self cacheFilePathWithResourceName:resourceName];
            return [responseObjectData writeToFile:path atomically:YES];
        }else{
            return NO;
        }
    }
    
    return NO;
}

+ (id)responseObjectWithResource:(NSString* )resourceName
{
    NSString* path = [self cacheFilePathWithResourceName:resourceName];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}


#pragma mark - file M

+ (NSString* )cacheFolderPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString* )cacheFilePathWithResourceName:(NSString* )resourceName
{
    resourceName = [NSString stringWithFormat:@"%@.plist",resourceName];
    NSMutableString* cacheFilePath = [[NSMutableString alloc] initWithString:[self cacheFolderPath]];
    return [cacheFilePath stringByAppendingPathComponent:resourceName];
}

+ (BOOL)createCacheFileWithResourceName:(NSString* )resourceName
{
    NSString* path = [self cacheFilePathWithResourceName:resourceName];
    NSFileManager* fileManger = [NSFileManager defaultManager];
    BOOL isExists = [fileManger fileExistsAtPath:path];
    BOOL isCreated = NO;
    if (!isExists) {
        isCreated = [fileManger createFileAtPath:path contents:[NSData data] attributes:nil];
    }else{
        isCreated = YES;
    }
    return isCreated;
}

@end






