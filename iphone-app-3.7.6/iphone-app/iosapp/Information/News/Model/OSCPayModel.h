//
//  OSCPayModel.h
//  iosapp
//
//  Created by 王恒 on 16/10/13.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayParameInfo : NSObject

@property (nonatomic,assign) NSInteger objType;
@property (nonatomic,assign) NSInteger objId;
@property (nonatomic,strong) NSString *attach;
@property (nonatomic,assign) NSInteger money;
@property (nonatomic,strong) NSString *subject;
@property (nonatomic,assign) NSInteger donater;
@property (nonatomic,assign) NSInteger author;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *returnUrl;
@property (nonatomic,strong) NSString *sign;
@property (nonatomic,strong) NSString *notifyUrl;

/**DES加密*/
-(void)encryptUseDES;

/**将model转化为dic*/
-(NSDictionary *)dictionaryFromModel;

@end

@interface PaySuccessInfo : NSObject

@property (nonatomic,assign) NSInteger objId;
@property (nonatomic,assign) NSInteger objType;
@property (nonatomic,assign) NSInteger money;
@property (nonatomic,strong) NSString *attach;
@property (nonatomic,strong) NSString *payInfo;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *pubDate;
@property (nonatomic,strong) NSString *orderCode;

@end

@interface PayInfo : NSObject

@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSString *time;
@property (nonatomic,strong) PaySuccessInfo *result;

@end
