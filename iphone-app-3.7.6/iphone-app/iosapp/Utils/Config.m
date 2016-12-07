//
//  Config.m
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "Config.h"
#import "TeamTeam.h"
#import "OSCUser.h"
#import "OSCUserItem.h"
#import "OSCNotice.h"

#import <SSKeychain.h>

NSString * const kService = @"OSChina";
NSString * const kAccount = @"account";
NSString * const kUserID = @"userID";

NSString * const kUserName = @"name";
NSString * const kPortrait = @"portrait";
NSString * const kPortraitURL = @"portraitURL";
//NSString * const kUserScore = @"score";
//NSString * const kFavoriteCount = @"favoritecount";
//NSString * const kFanCount = @"fans";
//NSString * const kFollowerCount = @"followers";
//
//NSString * const kJoinTime = @"jointime";
//NSString * const kDevelopPlatform = @"devplatform";
//NSString * const kExpertise = @"expertise";
//NSString * const kLocation = @"location";

NSString * const kTrueName = @"trueName";
NSString * const kSex = @"sex";
NSString * const kPhoneNumber = @"phoneNumber";
NSString * const kCorporation = @"corporation";
NSString * const kPosition = @"position";

NSString * const kTeamID = @"teamID";
NSString * const kTeamsArray = @"teams";

NSString * const kDesc = @"desc";
NSString * const kTweetCount = @"tweetCount";
NSString * const kGender = @"gender";

//new userItem
NSString * const kNewUserGender = @"newUserGender";

NSString * const kNewUserDesc = @"newUserDesc";
NSString * const kNewUserRelation = @"newUserRelation";

NSString * const kNewUserExpertise = @"newUserExpertise";
NSString * const kNewUserJoinDate = @"newUserJoinDate";
NSString * const kNewUserCity = @"newUserCity";
NSString * const kNewUserPlatform = @"newUserPlatform";
NSString * const kNewUserCompany = @"newUserCompany";
NSString * const kNewUserPosition = @"newUserPosition";

NSString * const kNewUserFollow = @"newUserFollow";
NSString * const kNewUserScore = @"newUserScore";
NSString * const kNewUserAnswer = @"newUserAnswer";
NSString * const kNewUserCollect = @"newUserCollect";
NSString * const kNewUserTweet = @"newUserTweet";
NSString * const kNewUserDiscuss = @"newUserDiscuss";
NSString * const kNewUserFans = @"newUserFans";
NSString * const kNewUserBlog = @"newUserBlog";

@implementation Config

// 保存账户信息
+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account ?: @"" forKey:kAccount];
    [userDefaults synchronize];
    
    [SSKeychain setPassword:password ?: @"" forService:kService account:account];
}

+ (NSArray *)getOwnAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kAccount];
    NSString *password = [SSKeychain passwordForService:kService account:account] ?: @"";
    
    if (account) {return @[account, password];}
    return nil;
}
//

+ (void)clearCookie
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"sessionCookies"];
}

// 活动报名暂存报名者信息
+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:actorName   forKey:kTrueName];
    [userDefaults setObject:@(sex)      forKey:kSex];
    [userDefaults setObject:phoneNumber forKey:kPhoneNumber];
    [userDefaults setObject:corporation forKey:kCorporation];
    [userDefaults setObject:position    forKey:kPosition];
    [userDefaults synchronize];
}

+ (NSArray *)getActivitySignUpInfomation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *name = [userDefaults objectForKey:kTrueName] ?: @"";
    NSNumber *sex = [userDefaults objectForKey:kSex] ?: @(0);
    NSString *phoneNumber = [userDefaults objectForKey:kPhoneNumber] ?: @"";
    NSString *corporation = [userDefaults objectForKey:kCorporation] ?: @"";
    NSString *position = [userDefaults objectForKey:kPosition] ?: @"";
    
    return @[name, sex, phoneNumber, corporation, position];
}


+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [NSString stringWithFormat:@"tweetTmp_%lld", userID];
    [userDefaults setObject:tweetText forKey:key];
    
    [userDefaults synchronize];
}

+ (int64_t)getOwnID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:kUserID];
}

+ (NSString *)getOwnUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:kUserName];
    if (userName) {return userName;}
    return @"";
}

+ (UIImage *)getPortrait
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *date = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userDefaults objectForKey:kPortrait]]];
    UIImage *portrait = [UIImage imageWithData:date];
    
    return portrait;
}

+ (NSString *)getTweetText
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *IdStr = [NSString stringWithFormat:@"tweetTmp_%lld", [Config getOwnID]];
    NSString *tweetText = [userDefaults objectForKey:IdStr];
    
    return tweetText;
}


#pragma mark - Team

+ (int)teamID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userDefaults objectForKey:kTeamID] intValue];
}

+ (void)setTeamID:(int)teamID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:@(teamID) forKey:kTeamID];
    [userDefaults synchronize];
}

+ (void)saveTeams:(NSArray *)teams
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *rawTeams = [NSMutableArray new];
    
    for (TeamTeam *team in teams) {
        [rawTeams addObject:@[@(team.teamID), team.name]];
    }
    [userDefaults setObject:rawTeams forKey:kTeamsArray];
    
    [userDefaults synchronize];
}

+ (NSMutableArray *)teams
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *rawTeams = [userDefaults objectForKey:kTeamsArray];
    NSMutableArray *teams = [NSMutableArray new];
    
    for (NSArray *rawTeam in rawTeams) {
        TeamTeam *team = [TeamTeam new];
        team.teamID = [((NSNumber *)rawTeam[0]) intValue];
        team.name = rawTeam[1];
        [teams addObject:team];
    }
    
    return teams;
}


+ (void)removeTeamInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kTeamID];
    [userDefaults removeObjectForKey:kTeamsArray];
}

//夜间状态
+ (void)saveWhetherNightMode:(BOOL)isNight
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(isNight) forKey:@"mode"];
    [userDefaults synchronize];
}
+ (BOOL)getMode
{
    return NO;      //去掉夜间模式
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    return [[userDefaults objectForKey:@"mode"] boolValue];
}

#pragma mark - 缓存消息推送条数

+ (void)saveNotice:(OSCNotice *)notice
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(notice.mention) forKey:@"noticeMention"];
    [userDefaults setObject:@(notice.letter) forKey:@"noticeLetter"];
    [userDefaults setObject:@(notice.review) forKey:@"noticeReview"];
    [userDefaults setObject:@(notice.fans) forKey:@"noticeFans"];
    [userDefaults setObject:@(notice.like) forKey:@"noticeLike"];
    
    [userDefaults synchronize];
}

+ (OSCNotice *)getNotice
{
    OSCNotice *notice = [OSCNotice new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    notice.mention = [[userDefaults objectForKey:@"noticeMention"] intValue];
    notice.letter = [[userDefaults objectForKey:@"noticeLetter"] intValue];
    notice.review = [[userDefaults objectForKey:@"noticeReview"] intValue];
    notice.fans = [[userDefaults objectForKey:@"noticeFans"] intValue];
    notice.like = [[userDefaults objectForKey:@"noticeLike"] intValue];
    
    return notice;
}

#pragma mark - new user profile

+ (void)saveNewProfile:(OSCUserItem *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:user.id         forKey:kUserID];
    [userDefaults setObject:user.name        forKey:kUserName];
    [userDefaults setObject:user.portrait    forKey:kPortrait];
    [userDefaults setObject:@(user.gender)   forKey:kNewUserGender];
    [userDefaults setObject:user.desc        forKey:kNewUserDesc];
    [userDefaults setObject:@(user.relation) forKey:kNewUserRelation];
    
    [userDefaults setInteger:user.statistics.follow  forKey:kNewUserFollow];
    [userDefaults setInteger:user.statistics.score   forKey:kNewUserScore];
    [userDefaults setInteger:user.statistics.answer  forKey:kNewUserAnswer];
    [userDefaults setInteger:user.statistics.collect forKey:kNewUserCollect];
    [userDefaults setInteger:user.statistics.tweet   forKey:kNewUserTweet];
    [userDefaults setInteger:user.statistics.discuss forKey:kNewUserDiscuss];
    [userDefaults setInteger:user.statistics.fans    forKey:kNewUserFans];
    [userDefaults setInteger:user.statistics.blog    forKey:kNewUserBlog];
    
    [userDefaults setObject:user.more.expertise forKey:kNewUserExpertise];
    [userDefaults setObject:user.more.joinDate  forKey:kNewUserJoinDate];
    [userDefaults setObject:user.more.city      forKey:kNewUserCity];
    [userDefaults setObject:user.more.platform  forKey:kNewUserPlatform];
    [userDefaults setObject:user.more.company   forKey:kNewUserCompany];
    [userDefaults setObject:user.more.position  forKey:kNewUserPosition];
    
    [userDefaults synchronize];
}

+ (void)updateNewProfile:(OSCUserItem *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:user.id         forKey:kUserID];
    [userDefaults setObject:user.name        forKey:kUserName];
    [userDefaults setObject:user.portrait    forKey:kPortrait];
    [userDefaults setObject:@(user.gender)   forKey:kNewUserGender];
    [userDefaults setObject:user.desc        forKey:kNewUserDesc];
    [userDefaults setObject:@(user.relation) forKey:kNewUserRelation];
    
    [userDefaults setInteger:user.statistics.follow  forKey:kNewUserFollow];
    [userDefaults setInteger:user.statistics.score   forKey:kNewUserScore];
    [userDefaults setInteger:user.statistics.answer  forKey:kNewUserAnswer];
    [userDefaults setInteger:user.statistics.collect forKey:kNewUserCollect];
    
    [userDefaults setInteger:user.statistics.tweet   forKey:kNewUserTweet];
    [userDefaults setInteger:user.statistics.discuss forKey:kNewUserDiscuss];
    [userDefaults setInteger:user.statistics.fans    forKey:kNewUserFans];
    [userDefaults setInteger:user.statistics.blog    forKey:kNewUserBlog];
    
    [userDefaults setObject:user.more.expertise forKey:kNewUserExpertise];
    [userDefaults setObject:user.more.joinDate  forKey:kNewUserJoinDate];
    [userDefaults setObject:user.more.city      forKey:kNewUserCity];
    [userDefaults setObject:user.more.platform  forKey:kNewUserPlatform];
    [userDefaults setObject:user.more.company   forKey:kNewUserCompany];
    [userDefaults setObject:user.more.position  forKey:kNewUserPosition];
    
    [userDefaults synchronize];
}

+ (void)clearNewProfile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(0) forKey:kUserID];
    [userDefaults setObject:@""  forKey:kUserName];//点击头像登录
    [userDefaults setObject:@""  forKey:kPortrait];
    [userDefaults setObject:@(0) forKey:kNewUserGender];
    [userDefaults setObject:@""  forKey:kNewUserDesc];
    [userDefaults setObject:@(0) forKey:kNewUserRelation];
    
    
    [userDefaults setObject:@(0) forKey:kNewUserFollow];
    [userDefaults setObject:@(0) forKey:kNewUserScore];
    [userDefaults setObject:@(0) forKey:kNewUserAnswer];
    [userDefaults setObject:@(0) forKey:kNewUserCollect];
    
    [userDefaults setObject:@(0) forKey:kNewUserTweet];
    [userDefaults setObject:@(0) forKey:kNewUserDiscuss];
    [userDefaults setObject:@(0) forKey:kNewUserFans];
    [userDefaults setObject:@(0) forKey:kNewUserBlog];
    
    [userDefaults setObject:@"" forKey:kNewUserExpertise];
    [userDefaults setObject:@"" forKey:kNewUserJoinDate];
    [userDefaults setObject:@"" forKey:kNewUserCity];
    [userDefaults setObject:@"" forKey:kNewUserPlatform];
    [userDefaults setObject:@"" forKey:kNewUserCompany];
    [userDefaults setObject:@"" forKey:kNewUserPosition];
    
    [userDefaults synchronize];
}

+ (OSCUserItem *)myNewProfile
{
    OSCUserItem *user = [OSCUserItem new];
    OSCUserStatistics *statistics = [OSCUserStatistics new];
    OSCUserMoreInfo *more = [OSCUserMoreInfo new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    user.id = [userDefaults integerForKey:kUserID];
    user.name = [userDefaults objectForKey:kUserName];
    user.portrait = [userDefaults objectForKey:kPortrait];
    
    user.gender = [[userDefaults objectForKey:kNewUserGender] intValue];
    user.desc = [userDefaults objectForKey:kNewUserDesc];
    user.relation = [[userDefaults objectForKey:kNewUserRelation] intValue];
    
    statistics.follow = [userDefaults integerForKey:kNewUserFollow];
    statistics.score = [userDefaults integerForKey:kNewUserScore];
    statistics.answer = [userDefaults integerForKey:kNewUserAnswer];
    statistics.collect = [userDefaults integerForKey:kNewUserCollect];
    
    statistics.tweet = [userDefaults integerForKey:kNewUserTweet];
    statistics.discuss = [userDefaults integerForKey:kNewUserDiscuss];
    statistics.fans = [userDefaults integerForKey:kNewUserFans];
    statistics.blog = [userDefaults integerForKey:kNewUserBlog];
    
    more.expertise = [userDefaults objectForKey:kNewUserExpertise];
    more.joinDate = [userDefaults objectForKey:kNewUserJoinDate];
    more.city = [userDefaults objectForKey:kNewUserCity];
    more.platform = [userDefaults objectForKey:kNewUserPlatform];
    more.company = [userDefaults objectForKey:kNewUserCompany];
    more.position = [userDefaults objectForKey:kNewUserPosition];
    
    user.statistics = statistics;
    user.more = more;
    
    return user;
}



@end
