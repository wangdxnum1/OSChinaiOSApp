//
//  OSCModelHandler.h
//  iosapp
//
//  Created by Graphic-one on 16/10/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSCModelHandler : NSObject

/**
 * OSCModelHandler 为开源中国App的model解耦层
 * 当前解析基于YYModel 1.0.4版本
 */

@end


@interface NSObject (OSCModelHandler_category)

+ (nullable instancetype)osc_modelWithJSON:(id)json;

+ (nullable instancetype)osc_modelWithDictionary:(NSDictionary *)dictionary;

- (BOOL)osc_modelSetWithJSON:(id)json;

- (BOOL)osc_modelSetWithDictionary:(NSDictionary *)dic;

- (nullable id)osc_modelToJSONObject;

- (nullable NSData *)osc_modelToJSONData;

- (nullable NSString *)osc_modelToJSONString;

- (nullable id)osc_modelCopy;

- (void)osc_modelEncodeWithCoder:(NSCoder *)aCoder;

- (id)osc_modelInitWithCoder:(NSCoder *)aDecoder;

- (NSUInteger)osc_modelHash;

- (BOOL)osc_modelIsEqual:(id)model;

- (NSString *)osc_modelDescription;

@end


@interface NSArray (OSCModelHandler_category)
/**
 * 字典数组 转 模型数组
 *
 *@param  cls     模型对应的class
 *@param  json    字典数组JSON
 *@return 返回转换好的模型数组
 */
+ (nullable NSArray *)osc_modelArrayWithClass:(Class)cls
                                         json:(id)json;

@end

@interface NSDictionary (OSCModelHandler_category)
/**
 * 单个 字典 转 模型
 *
 *@param  cls     模型对应的class
 *@param  json    字典数组JSON
 *@return 返回转换好的模型
 */
+ (nullable NSDictionary *)osc_modelDictionaryWithClass:(Class)cls
                                                   json:(id)json;

@end



/**
@protocol OSCModelHandler_Potocol <NSObject>
@optional

+ (nullable NSDictionary<NSString *, id> *)osc_modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)osc_modelContainerPropertyGenericClass;

+ (nullable Class)osc_modelCustomClassForDictionary:(NSDictionary *)dictionary;

+ (nullable NSArray<NSString *> *)osc_modelPropertyBlacklist;

+ (nullable NSArray<NSString *> *)osc_modelPropertyWhitelist;

- (NSDictionary *)osc_modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)osc_modelCustomTransformFromDictionary:(NSDictionary *)dic;

- (BOOL)osc_modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end
 */


NS_ASSUME_NONNULL_END







