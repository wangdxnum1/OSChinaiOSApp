//
//  OSCModelHandler.m
//  iosapp
//
//  Created by Graphic-one on 16/10/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCModelHandler.h"

@implementation OSCModelHandler

@end



@implementation NSObject (OSCModelHandler_category)

+ (nullable instancetype)osc_modelWithJSON:(id)json{
    return [self modelWithJSON:json];
}

+ (nullable instancetype)osc_modelWithDictionary:(NSDictionary *)dictionary{
    return [self modelWithDictionary:dictionary];
}

- (BOOL)osc_modelSetWithJSON:(id)json{
    return [self modelSetWithJSON:json];
}

- (BOOL)osc_modelSetWithDictionary:(NSDictionary *)dic{
    return [self modelSetWithDictionary:dic];
}

- (nullable id)osc_modelToJSONObject{
    return [self modelToJSONObject];
}

- (nullable NSData *)osc_modelToJSONData{
    return [self modelToJSONData];
}

- (nullable NSString *)osc_modelToJSONString{
    return [self modelToJSONString];
}

- (nullable id)osc_modelCopy{
    return [self modelCopy];
}

- (void)osc_modelEncodeWithCoder:(NSCoder *)aCoder{
    [self modelEncodeWithCoder:aCoder];
}

- (id)osc_modelInitWithCoder:(NSCoder *)aDecoder{
    return [self modelInitWithCoder:aDecoder];
}

- (NSUInteger)osc_modelHash{
    return [self modelHash];
}

- (BOOL)osc_modelIsEqual:(id)model{
    return [self modelIsEqual:model];
}

- (NSString *)osc_modelDescription{
    return [self modelDescription];
}
@end



@implementation NSArray (OSCModelHandler_category)

+ (nullable NSArray *)osc_modelArrayWithClass:(Class)cls
                                         json:(id)json
{
    return [self modelArrayWithClass:cls json:json];
}

@end



@implementation NSDictionary (OSCModelHandler_category)

+ (NSDictionary *)osc_modelDictionaryWithClass:(Class)cls
                                          json:(id)json
{
    return [self modelDictionaryWithClass:cls json:json];
}

@end













