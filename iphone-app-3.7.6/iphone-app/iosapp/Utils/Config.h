//
//  Config.h
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OSCUser;
@class OSCUserItem;
@class OSCNotice;

@interface Config : NSObject

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password;

+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position;

+ (void)clearCookie;

+ (NSArray *)getOwnAccountAndPassword;
+ (int64_t)getOwnID;
+ (NSString *)getOwnUserName;
+ (NSArray *)getActivitySignUpInfomation;
+ (UIImage *)getPortrait;

+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID;
+ (NSString *)getTweetText;

+ (int)teamID;
+ (void)setTeamID:(int)teamID;
+ (void)saveTeams:(NSArray *)teams;
+ (NSMutableArray *)teams;
+ (void)removeTeamInfo;
+ (void)saveWhetherNightMode:(BOOL)isNight;
+ (BOOL)getMode;

+ (void)saveNotice:(OSCNotice *)notice;
+ (OSCNotice *)getNotice;

//new userItem
+ (void)saveNewProfile:(OSCUserItem *)user;
+ (void)updateNewProfile:(OSCUserItem *)user;
+ (void)clearNewProfile;
+ (OSCUserItem *)myNewProfile;

@end
