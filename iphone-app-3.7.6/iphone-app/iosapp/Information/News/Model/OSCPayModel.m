//
//  OSCPayModel.m
//  iosapp
//
//  Created by 王恒 on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPayModel.h"
#import "OSCModelHandler.h"
#import <MJExtension.h>
#include <CommonCrypto/CommonCryptor.h>

#define key @"19328_etanod_cso_4_yek_sed_a_si_sihT"

@interface PayParameInfo() {
    NSMutableArray *_Keys;
}

@end

@implementation PayParameInfo

-(NSString *)modelToString{
    NSString *modelString = @"";
    NSDictionary *dic = [self mj_keyValues];
    NSArray *allKeys = [dic allKeys];
    NSLog(@"%@",dic);
    _Keys = [allKeys mutableCopy];
    for (NSString *currentKey in allKeys) {
        if (![currentKey isEqualToString:@"sign"]) {
            if([dic[currentKey] isKindOfClass:[NSString class]] && ![dic[currentKey] isEqualToString:@""]){
                NSString *subString = @"";
                if ([allKeys indexOfObject:currentKey] == 0) {
                    subString = [NSString stringWithFormat:@"%@=%@",currentKey,dic[currentKey]];
                }else{
                    subString = [NSString stringWithFormat:@"&%@=%@",currentKey,dic[currentKey]];
                }
                modelString = [modelString stringByAppendingString:subString];
            }else if ([dic[currentKey] isKindOfClass:[NSNumber class]]){
                NSString *subString = @"";
                if ([allKeys indexOfObject:currentKey] == 0) {
                    subString = [NSString stringWithFormat:@"%@=%@",currentKey,dic[currentKey]];
                }else{
                    subString = [NSString stringWithFormat:@"&%@=%@",currentKey,dic[currentKey]];
                }
                modelString = [modelString stringByAppendingString:subString];
            }
        }
    }
    return modelString;
}

-(void)encryptUseDES{
    NSString *clearText = [self modelToString];
    NSLog(@"%@",clearText);
    
    NSData *textData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String], kCCBlockSizeDES,
                                          NULL,
                                          [textData bytes]  , dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [self parseByte2HexString:dataTemp];
        self.sign = plainText;
        [_Keys addObject:@"sign"];
    }else{
        NSLog(@"DES加密失败");
    }
}

/**二进制转十六进制字符串*/
- (NSString *) parseByte2HexString:(NSData *) data{
    const size_t size = [data length];
    Byte* bytes = (Byte*)[data bytes];
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    if(bytes)
    {
        for (int i = 0; i < size; i++)
        {
            NSString *hexByte = [NSString stringWithFormat:@"%X",bytes[i] & 0xff]; ///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
        }
    }
    return hexStr;
}

-(NSDictionary *)dictionaryFromModel{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSDictionary *modelDic = [self mj_keyValues];
    for (NSString *currentKey in _Keys) {
        [dic setObject:modelDic[currentKey] forKey:currentKey];
    }
    return dic;
}

@end

@implementation PaySuccessInfo



@end

@implementation PayInfo

+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"result" : [PaySuccessInfo class]};
}

@end
