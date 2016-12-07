//
//  Utils.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "Utils.h"
#import "AppDelegate.h"
#import "OSCAPI.h"

#import "OSCModelHandler.h"
#import "OSCMenuItem.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <CommonCrypto/CommonDigest.h>
#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <objc/runtime.h>
#import <Reachability.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <GRMustache.h>
#import <DTCoreText.h>


@implementation Utils


#pragma mark - 处理API返回信息

+ (NSAttributedString *)getAppclient:(int)clientType
{
    NSMutableAttributedString *attributedClientString;
    if (clientType > 1 && clientType <= 6) {
        NSArray *clients = @[@"", @"", @"手机", @"Android", @"iPhone", @"Windows Phone", @"微信"];
        
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForEnum:FAMobile]
                                                                        attributes:@{
                                                                                     NSFontAttributeName: [UIFont fontAwesomeFontOfSize:13],
                                                                                     }];
        
        [attributedClientString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", clients[clientType]]]];
    } else {
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    return attributedClientString;
}


+ (NSAttributedString *)getAppclientName:(int)clientType
{
    NSMutableAttributedString *attributedClientString;
    if (clientType > 1 && clientType <= 6) {
        NSArray *clients = @[@"", @"", @"手机", @"Android", @"iPhone", @"Windows Phone", @"微信"];
        
        
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", clients[clientType]]];

    } else {
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    return attributedClientString;
}

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews
{
    if (relativeNews == nil || [relativeNews count] == 0) {
        return @"";
    }
    
    NSString *middle = @"";
    for (NSArray *news in relativeNews) {
        middle = [NSString stringWithFormat:@"%@<a href=%@>%@</a><p/>", middle, news[1], news[0]];
    }
    return [NSString stringWithFormat:@"相关文章<div style='font-size:14px'><p/>%@</div>", middle];
}

+ (NSString *)generateTags:(NSArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    } else {
        NSString *result = @"";
        for (NSString *tag in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;", result, tag, tag];
        }
        return result;
    }
}




#pragma mark - 通用

#pragma mark - emoji Dictionary

+ (NSDictionary *)emojiDict
{
    static dispatch_once_t once;
    static NSDictionary *emojiDict;
    
    dispatch_once(&once, ^ {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emoji" ofType:@"plist"];
        emojiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    });
    
    return emojiDict;
}

#pragma mark 信息处理

+ (NSAttributedString *)attributedTimeString:(NSDate *)date
{
//    NSString *rawString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date timeAgoSinceNow]];
    NSString *rawString = [date timeAgoSinceNow];
    
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:rawString
                                                                         attributes:@{
                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
                                                                                      }];
    
    return attributedTime;
}

+ (NSAttributedString *)newTweetAttributedTimeString:(NSDate *)date
{
//    NSString *rawString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], ];
    
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:[date timeAgoSinceNow]
                                                                         attributes:@{
                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
                                                                                      }];
    
    return attributedTime;
}

// 参考 http://www.cnblogs.com/ludashi/p/3962573.html

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:rawString attributes:nil];
    return [Utils emojiStringFromAttrString:attrString];
}

+ (NSAttributedString *)emojiStringFromAttrString:(NSAttributedString*)attrString
{
    NSMutableAttributedString *emojiString = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
    NSDictionary *emoji = self.emojiDict;

    NSString *pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]|:[a-zA-Z0-9\\u4e00-\\u9fa5_]+:";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:attrString.string options:0 range:NSMakeRange(0, attrString.string.length)];
    
    NSMutableArray *emojiArray = [NSMutableArray arrayWithCapacity:resultsArray.count];
	
    
    for (NSTextCheckingResult *match in resultsArray) {
        NSRange range = [match range];
        NSString *emojiName = [attrString.string substringWithRange:range];
        
        if ([emojiName hasPrefix:@"["] && emoji[emojiName]) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            if ([UIImage imageNamed:emoji[emojiName]]) {
                textAttachment.image = [UIImage imageNamed:emoji[emojiName]];
                [textAttachment adjustY:-3];
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
            }else{
                NSAttributedString *alertString = [[NSAttributedString alloc] initWithString:@"[表情]"];
                [emojiArray addObject: @{@"image": alertString, @"range": [NSValue valueWithRange:range]}];
            }
        } else if ([emojiName hasPrefix:@":"]) {
            if (emoji[emojiName]) {
                [emojiArray addObject:@{@"text": emoji[emojiName], @"range": [NSValue valueWithRange:range]}];
            } else {
                UIImage *emojiImage = [UIImage imageNamed:[emojiName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]];
                if (emojiImage) {
                    NSTextAttachment *textAttachment = [NSTextAttachment new];
                    textAttachment.image = emojiImage;
                    [textAttachment adjustY:-3];
                    NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
                }else{
                    NSAttributedString *alertString = [[NSAttributedString alloc] initWithString:@"[表情]"];
                    [emojiArray addObject: @{@"image": alertString, @"range": [NSValue valueWithRange:range]}];
                }
            }
        }
    }
    
    for (NSInteger i = emojiArray.count -1; i >= 0; i--) {
        NSRange range;
        [emojiArray[i][@"range"] getValue:&range];
        if (emojiArray[i][@"image"]) {
            [emojiString replaceCharactersInRange:range withAttributedString:emojiArray[i][@"image"]];
        } else {
            [emojiString replaceCharactersInRange:range withString:emojiArray[i][@"text"]];
        }
    }
    
    return emojiString;
}

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)html
{
    // [NSAttributedAttributedString initWithData:options:documentAttributes:error:] is very slow
    // use DTCoreText instead
    
    if (![html hasPrefix:@"<"]) {
        html = [NSString stringWithFormat:@"<span>%@</span>", html]; // DTCoreText treat raw string as <p> element
    }
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSAttributedString alloc] initWithHTMLData:data options:@{ DTUseiOS6Attributes: @YES}
                                     documentAttributes:nil];
}

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttrString.length)];
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
                                  privateChatType:(BOOL)isSelf
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttrString.length)];
    if (isSelf) {
        [mutableAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mutableAttrString.length)];
    }else{
        [mutableAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, mutableAttrString.length)];
    }
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}

+ (NSString *)convertRichTextToRawText:(UITextView *)textView
{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
                                                    if (!attachment) {return;}
                                        
                                                    NSString *emojiStr = objc_getAssociatedObject(attachment, @"emoji");
                                                    [rawText insertString:emojiStr atIndex:range.location];
                                                }];
    
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        if(!emojiToText[emoji]){
            [rawText replaceCharactersInRange:match.range withString:@"[表情]"];
        }else{
            [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
        }
    }
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSData *)compressImage:(UIImage *)image
{
    CGSize size = [self scaleSize:image.size];
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 0.7f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}

+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    } else {
        return CGSizeMake(800 * width / height, 800);
    }
}


+ (BOOL)isURL:(NSString *)string
{
    NSString *pattern = @"^(http|https)://.*?$(net|com|.com.cn|org|me|)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    return [urlPredicate evaluateWithObject:string];
}


+ (NSInteger)networkStatus
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.oschina.net"];
    return reachability.currentReachabilityStatus;
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}


#pragma mark UI处理

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent
{
    return min + (max - min) * percent;
}

+ (MBProgressHUD *)createHUD
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [window addSubview:HUD];
    [HUD showAnimated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    //[HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
    
    return HUD;
}

+ (UIImage *)createQRCodeFromString:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [QRFilter setValue:stringData forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CGFloat scale = 5;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:QRFilter.outputImage fromRect:QRFilter.outputImage.extent];
    
    //Scale the image usign CoreGraphics
    CGFloat width = QRFilter.outputImage.extent.size.width * scale;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return image;
}

+ (NSAttributedString *)attributedCommentCount:(int)commentCount
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FACommentsO], commentCount];
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
                                                                                              }];
    
    return attributedCommentCount;
}


+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html" inDirectory:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *mutableData = [data mutableCopy];
    [mutableData setObject:@(((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode)
                    forKey:@"night"];
    
    return [GRMustacheTemplate renderObject:mutableData fromString:template error:nil];
}

/*
 数字限制字符串
 */
+ (NSString *)numberLimitString:(int)number
{
    NSString *numberStr = @"";
    if (number >= 0 && number < 1000) {
        numberStr = [NSString stringWithFormat:@"%d", number];
    } else if (number >= 1000 && number < 10000) {
        int integer = number / 1000;
        int decimal = number % 1000 / 100;
        
        numberStr = [NSString stringWithFormat:@"%d.%dk", integer, decimal];
    } else {
        int inte = number / 1000;
        numberStr = [NSString stringWithFormat:@"%dk", inte];
    }
    
    return numberStr;
}

+ (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+ (NSString *)sha1:(NSString *)input
{
//    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

#pragma mark - 选择边框，主题色输入色，红色警告色
+ (void)setButtonBorder:(UIView *)view isFail:(BOOL)isFail isEditing:(BOOL)isEditing
{
    if (isFail) {
        view.layer.borderWidth = 2;
        view.layer.borderColor = [UIColor colorWithHex:0xe35b5a].CGColor;
    } else {
        if (isEditing) {
            view.layer.borderWidth = 2;
            view.layer.borderColor = [UIColor newSectionButtonSelectedColor].CGColor;
        } else {
            view.layer.borderWidth = 0;
        }
    }
}

#pragma makr - 检测是否为手机号
+ (BOOL)validateMobile:(NSString *)mobileNum
{
    NSString *regex = @"^1[3|5|7|8][0-9]\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject:mobileNum])
    {
        return NO;
    }
    
    else
    {
        return YES;
    }
}

#pragma mark - image new
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


@implementation Utils (SubMenuManger)

/** 定制化分栏*/
+ (NSArray<OSCMenuItem* >* )allLocalMenuItems{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"subMenuItems.plist" ofType:nil];
    NSArray* localMenusArr = [NSArray arrayWithContentsOfFile:filePath];
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:localMenusArr];
    return meunItems;
}

///获取全部本地的 menuNames && meunTokens
+ (NSArray<NSString* >* )allLocalMenuNames{
    NSArray* meunItems = [self allLocalMenuItems];
    NSMutableArray* allNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in meunItems) {
        [allNames addObject:curItem.name];
    }
    return allNames.copy;
}
+ (NSArray<NSString* >* )allLocalMenuTokens{
    NSArray* meunItems = [self allLocalMenuItems];
    NSMutableArray* allTokens = @[].mutableCopy;
    for (OSCMenuItem* curItem in meunItems) {
        [allTokens addObject:curItem.token];
    }
    return allTokens.copy;
}

///获取全部已选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allSelectedMenuNames{
    NSArray* chooseItemTokens = [self allSelectedMenuTokens];
    NSArray<OSCMenuItem* >* allChooseMenuItems = [self conversionMenuItemsWithMenuTokens:chooseItemTokens];
    NSMutableArray* allNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in allChooseMenuItems) {
        [allNames addObject:curItem.name];
    }
    return allNames.copy;
}
+ (NSArray<NSString* >* )allSelectedMenuTokens{
    NSArray* chooseItemTokens = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaults_ChooseMenus];
    if (chooseItemTokens.count == 0) {
        chooseItemTokens = [self getNomalSelectedMenuItemTokens];
        [self updateUserSelectedMenuListWithMenuTokens:chooseItemTokens];
    }
    return chooseItemTokens;
}

///获取全部未选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allUnselectedMenuNames{
    NSArray<NSString* >* allUnselectedMenuTokens = [self allUnselectedMenuTokens];
    NSArray<OSCMenuItem* >* allUnselectedMenuItems = [self conversionMenuItemsWithMenuTokens:allUnselectedMenuTokens];
    allUnselectedMenuItems = [self sortTransformation:allUnselectedMenuItems];
    NSMutableArray* allUnselectedNames = @[].mutableCopy;
    for (OSCMenuItem* curMenuItem in allUnselectedMenuItems) {
        [allUnselectedNames addObject:curMenuItem.name];
    }
    return allUnselectedNames.copy;
}
+ (NSArray<NSString* >* )allUnselectedMenuTokens{
    NSArray* allTokens = [self allLocalMenuTokens];
    NSArray* allSelectedMenuTokens = [self allSelectedMenuTokens];
    
    NSMutableArray* unselectedTokens = @[].mutableCopy;
    for (NSString* curToken in allTokens) {
        if (![allSelectedMenuTokens containsObject:curToken]) {
            [unselectedTokens addObject:curToken];
        }
    }
    return unselectedTokens.copy;
}
/** name token item 相互转换*/
///用name转换成具体menuItem
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuNames:(NSArray<NSString* >* )menuNames{
    NSArray<OSCMenuItem* >* allMeunItems = [self allLocalMenuItems];
    NSMutableArray* conversionMenuItem = @[].mutableCopy;
//    for (OSCMenuItem* curMenuItem in allMeunItems) {
//        if ([menuNames containsObject:curMenuItem.name]) {
//            [conversionMenuItem addObject:curMenuItem];
//        }
//        if (conversionMenuItem.count == menuNames.count) {
//            return conversionMenuItem.copy;
//        }
//    }
    NSMutableArray *allName = [NSMutableArray array];
    for(OSCMenuItem* curMenuItem in allMeunItems){
        [allName addObject:curMenuItem.name];
    }
    for (NSString *name in menuNames) {
        NSInteger index = [allName indexOfObject:name];
        OSCMenuItem *item = allMeunItems[index];
        [conversionMenuItem addObject:item];
    }
    return conversionMenuItem.copy;
}
///用token转换成具体menuItem
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuTokens:(NSArray<NSString* >* )menuTokens{
    NSArray<OSCMenuItem* >* allMeunItems = [self allLocalMenuItems];
    NSMutableArray* conversionMenuItem = @[].mutableCopy;
//    for (OSCMenuItem* curMenuItem in allMeunItems) {
//        if ([menuTokens containsObject:curMenuItem.token]) {
//            [conversionMenuItem addObject:curMenuItem];
//        }
//        if (conversionMenuItem.count == menuTokens.count) {
//            return conversionMenuItem.copy;
//        }
//    }
    NSMutableArray *allToken = [NSMutableArray array];
    for(OSCMenuItem* curMenuItem in allMeunItems){
        [allToken addObject:curMenuItem.token];
    }
    for (NSString *token in menuTokens) {
        NSInteger index = [allToken indexOfObject:token];
        OSCMenuItem *item = allMeunItems[index];
        [conversionMenuItem addObject:item];
    }
    return conversionMenuItem.copy;
}
///用menuItem转换成token
+ (NSArray<NSString* >* )conversionMenuTokensWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems{
    NSMutableArray* meunTokens = @[].mutableCopy;
    for (OSCMenuItem* menuItem in menuItems) {
        [meunTokens addObject:menuItem.token];
    }
    return meunTokens.copy;
}
///用menuItem转换成name
+ (NSArray<NSString* >* )conversionMenuNamesWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems{
    NSMutableArray* meunNames = @[].mutableCopy;
    for (OSCMenuItem* menuItem in menuItems) {
        [meunNames addObject:menuItem.name];
    }
    return meunNames.copy;
}

///更新本地plist表(含全部分栏信息)
+ (void)updateLocalMenuList{
    /**
    NSString* requestURL = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_INFORMATION_SUB_ENUM];
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:requestURL
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                
            }
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
    }];
     */
}
+ (void)usingLocatMenuListUpdateUserMenuList{
    NSArray<NSString* >* allSelectedMenuTokens = [self allSelectedMenuTokens];
    NSArray<NSString* >* allLocalMenuTokens = [self allLocalMenuTokens];
    NSMutableArray* updateUserList = @[].mutableCopy;
    for (NSString* curToken in allSelectedMenuTokens) {
        if ([allLocalMenuTokens containsObject:curToken]) {
            [updateUserList addObject:curToken];
        }
    }
    [self updateUserSelectedMenuListWithMenuTokens:updateUserList.copy];
}
///更新UserSelectedMeunList(包含用户选中的分栏信息)
+ (void)updateUserSelectedMenuListWithMenuItems:(NSArray<OSCMenuItem* >* )newUserMenuList_items{
    NSArray<NSString* >* menuTokens = [self conversionMenuTokensWithMenuItems:newUserMenuList_items];
    [self updateUserSelectedMenuListWithMenuTokens:menuTokens];
}
+ (void)updateUserSelectedMenuListWithMenuTokens:(NSArray<NSString* >* )newUserMenuList_tokens{
    [[NSUserDefaults standardUserDefaults] setObject:newUserMenuList_tokens forKey:kUserDefaults_ChooseMenus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)updateUserSelectedMenuListWithMenuNames:(NSArray<NSString* >* )newUserMenuList_names{
    NSArray<OSCMenuItem* >* menuItems = [self conversionMenuItemsWithMenuNames:newUserMenuList_names];
    NSArray<NSString* >* menuTokens = [self conversionMenuTokensWithMenuItems:menuItems];
    [self updateUserSelectedMenuListWithMenuTokens:menuTokens];
}


+ (NSArray<NSString* >* )getNomalSelectedMenuItemTokens{
    NSArray* nomalToken = @[
                            @"d6112fa662bc4bf21084670a857fbd20",//推荐
                            @"df985be3c5d5449f8dfb47e06e098ef9",//推荐博客
                            @"b4ca1962b3a80823c6138441015d9836",//最新软件
                            @"e3e35d14a62b4f816ec878b6597b60aa",//热门咨讯
                            @"299975006aa7f9b8a158deeb0d27a011",//码云推荐
                            @"727d77c15b2ca641fff392b779658512",//线下活动
                            @"1abf09a23a87442184c2f9bf9dc29e35",//每日一搏
                            @"263ee86f538884e70ee1ee50aed759b6",//每日乱弹
                            ];
    return nomalToken;
}

///根据item的order进行排序
+ (NSArray<OSCMenuItem* >* )sortTransformation:(NSArray<OSCMenuItem* >* )items{
    NSMutableArray<OSCMenuItem* >* sortMutableArray = [NSMutableArray arrayWithCapacity:items.count];
    
    /**test
    NSMutableArray<NSNumber* >* orderArray = @[].mutableCopy;
    for (OSCMenuItem* item in items) {
        [orderArray addObject:@(item.order)];
    }
    NSLog(@"%@",orderArray);
     */
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    sortMutableArray = [items sortedArrayUsingDescriptors:@[sortDescriptor]].copy;
    
    /**
    for (OSCMenuItem* item in sortMutableArray) {
        [orderArray addObject:@(item.order)];
    }
    NSLog(@"%@",orderArray);
     */
    
    return sortMutableArray;
}

/** 过渡版分栏读写接口*/
+ (NSString* )originMenuFilePath{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_original.json" ofType:nil];
    return filePath;
}
+ (NSString* )activeMenuItemFilePath{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_active.json" ofType:nil];
    return filePath;
}
+ (NSArray<OSCMenuItem* >* )getOriginMenuItem{//获取全部分栏信息
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_original.json" ofType:nil];
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    id localMenusArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:localMenusArr];
    return meunItems;
}
+ (NSArray<NSString* >* )getOriginMenuItemNames{
    NSArray<OSCMenuItem* >* originItems = [self getOriginMenuItem];
    
    NSMutableArray* originNames = @[].mutableCopy;
    for (OSCMenuItem* meunItem in originItems) {
        [originNames addObject:meunItem.name];
    }
    return originNames.copy;
}
+ (NSArray<OSCMenuItem* >* )getActiveMenuItem{//获取用户选择分栏信息
    NSArray* chooseMenus = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaults_ChooseMenus];
    if (chooseMenus.count == 0 || !chooseMenus) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_active.json" ofType:nil];
        NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
        chooseMenus = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    }
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:chooseMenus];
    return meunItems;
}

+ (NSArray<NSString* >* )allSelected_MenuNames{
    NSArray<OSCMenuItem* >* activeMenuItems = [self getActiveMenuItem];
    NSMutableArray* allSelected_MenuNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in activeMenuItems) {
        [allSelected_MenuNames addObject:curItem.name];
    }
    return allSelected_MenuNames.copy;
}
+ (NSArray<NSString* >* )allUnselected_MenuNames{
    NSArray<OSCMenuItem* >* originMenuItems = [self getOriginMenuItem];
    NSArray<OSCMenuItem* >* activeMenuItems = [self getActiveMenuItem];
    
    NSMutableArray<OSCMenuItem* >* allUnselected_MenuItems = @[].mutableCopy;
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < activeMenuItems.count; i++) {
        [nameArray addObject:activeMenuItems[i].name];
    }
    
    for (OSCMenuItem* curItem in originMenuItems) {
        if (![nameArray containsObject:curItem.name]) {
            [allUnselected_MenuItems addObject:curItem];
        }
    }
    
//    NSArray<OSCMenuItem* >* allUnselected_Sort_MenuItems = [self sortTransformation:allUnselected_MenuItems.copy];
    NSArray<OSCMenuItem* >* allUnselected_Sort_MenuItems = allUnselected_MenuItems.copy;

    
    NSMutableArray<NSString* >* allUnselected_MenuNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in allUnselected_Sort_MenuItems) {
        [allUnselected_MenuNames addObject:curItem.name];
    }
    
    return allUnselected_MenuNames.copy;
}
+ (void)updateUserSelectedMenuList_With_MenuNames:(NSArray<NSString* >* )newUserMenuList_names{
    NSArray<OSCMenuItem* >* allOriginItems = [self getOriginMenuItem];
    NSArray<NSString* >* allOriginItemNames = [self getOriginMenuItemNames];
    
    NSMutableArray<OSCMenuItem* >* userSelectedArr = @[].mutableCopy;
    for (NSString* curItemName in newUserMenuList_names) {
        for (NSString* curOriginItemName in allOriginItemNames) {
            if ([curItemName isEqualToString:curOriginItemName]) {
                NSInteger index = [allOriginItemNames indexOfObject:curOriginItemName];
                OSCMenuItem* indexItem = [allOriginItems objectAtIndex:index];
                [userSelectedArr addObject:indexItem];
            }
        }
    }
    
    NSArray* dicArray = [NSArray mj_keyValuesArrayWithObjectArray:userSelectedArr.copy];
    [[NSUserDefaults standardUserDefaults] setObject:dicArray forKey:kUserDefaults_ChooseMenus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSArray<OSCMenuItem* >* )conversionMenuItems_With_MenuNames:(NSArray<NSString* >* )menuNames{
    NSArray<OSCMenuItem* >* originMenuItem = [self getOriginMenuItem];
    NSArray<NSString* >* originMenuName = [self getOriginMenuItemNames];
    
    NSMutableArray<OSCMenuItem* >* conversionMenuItems = @[].mutableCopy;
    for (NSString* curName in menuNames) {
        for (NSString* originName in originMenuName) {
            if ([curName isEqualToString:originName]) {
                NSInteger index = [originMenuName indexOfObject:originName];
                OSCMenuItem* indexItem = [originMenuItem objectAtIndex:index];
                [conversionMenuItems addObject:indexItem];
            }
        }
    }
    return conversionMenuItems.copy;
}
@end



















