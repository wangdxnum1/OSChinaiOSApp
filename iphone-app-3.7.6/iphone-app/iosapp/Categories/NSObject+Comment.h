//
//  NSObject+Comment.h
//  iosapp
//
//  Created by Graphic-one on 16/11/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Comment)


@end



@interface NSObject (Cache)

/**
 缓存文件名的命名规则 ::
 请求URL+参数字典的Desc+用户ID ---'hash'---> hash.plist
 
 持久化 
 result:{
         "items":[
                     { item 1... },
                     { item 2... },
                     { item 3... }
                 ],
         "nextPageToken" :"string",
         "prevPageToken" :"string",
         "totalResults"  :"integer",
         "resultsPerPage":"integer"
         }
 */

+ (NSString* )cacheResourceNameWithURL:(NSString* )requestUrl
               parameterDictionaryDesc:(nullable NSString* )paraDicDesc;

+ (NSString* )cacheBannerResourceNameWithURL:(NSString* )requestUrl
                               bannerCatalog:(OSCInformationListBannerType)catalog;

/** 网络请求handle */
+ (BOOL)handleResponseObject:(id)responseObject resource:(NSString* )resourceName;

+ (id)responseObjectWithResource:(NSString* )resourceName;


#pragma mark - file M
+ (NSString* )cacheFolderPath;///缓存文件夹的全路径

+ (NSString* )cacheFilePathWithResourceName:(NSString* )resourceName;///根据'resourceName'获取文件的全路径

+ (BOOL)createCacheFileWithResourceName:(NSString* )resourceName;///根据'resourceName'创建缓存文件夹下面的文件

@end

NS_ASSUME_NONNULL_END
