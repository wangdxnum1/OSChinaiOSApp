//
//  TokenManager.m
//  iosapp
//
//  Created by Graphic-one on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TokenManager.h"

NSString* const Information_List_Key = @"Information_List_Key";

NSString* const Blog_List_Key = @"Blog_List_Key";

NSString* const QandA_List_Key = @"QandA_List_Key";

NSString* const Activity_List_Key = @"Activity_List_Key";

@implementation TokenManager

+(NSString *)getTokenWithKey:(TokenType)type{
    
    NSUserDefaults* singleUserDefault = [NSUserDefaults standardUserDefaults];
    
    switch (type) {
        case TokenTypeInformation:
            return [singleUserDefault valueForKey:Information_List_Key];
            break;
            
        case TokenTypeBlog:
            return [singleUserDefault valueForKey:Blog_List_Key];
            break;
            
        case TokenTypeQandA:
            return [singleUserDefault valueForKey:QandA_List_Key];
            break;
            
        case TokenTypeActivity:
            return [singleUserDefault valueForKey:Activity_List_Key];
            break;
            
        default:
            NSAssert(true,@"type 必须是存在的值");
            break;
    }
}


+(BOOL)saveTokenWithKey:(TokenType)type newToken:(NSString *)token{
    
    if (token.length == 0) {return NO;}
    
    NSUserDefaults* singleUserDefault = [NSUserDefaults standardUserDefaults];
    
    switch (type) {
        case TokenTypeInformation:
            [singleUserDefault setValue:token forKey:Information_List_Key];
            return [singleUserDefault boolForKey:Information_List_Key];
            break;
            
        case TokenTypeBlog:
            [singleUserDefault setValue:token forKey:Blog_List_Key];
            return [singleUserDefault boolForKey:Blog_List_Key];
            break;
            
        case TokenTypeQandA:
            [singleUserDefault setValue:token forKey:QandA_List_Key];
            return [singleUserDefault boolForKey:QandA_List_Key];
            break;
            
        case TokenTypeActivity:
            [singleUserDefault setValue:token forKey:Activity_List_Key];
            return [singleUserDefault boolForKey:Activity_List_Key];
            break;
            
        default:
            NSAssert(true,@"type 必须是存在的值 && token 必须合法");
            break;
    }
}

/** 防御性编程 防止从userDefaults取空value 或者 以不存在的key去访问字典*/
-(void)setNilValueForKey:(NSString *)key{}
-(id)valueForUndefinedKey:(NSString *)key{return nil;}

@end
